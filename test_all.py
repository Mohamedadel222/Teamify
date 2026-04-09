import requests, json, uuid

BASE = 'http://127.0.0.1:5022'
tag = uuid.uuid4().hex[:6]
results = []


def test(name, passed, detail=''):
    results.append((name, passed, detail))
    mark = 'PASS' if passed else 'FAIL'
    print(f'[{mark}] {name}' + (f' -> {detail}' if detail else ''))


# =================== AUTH ===================

# 1. Register
r = requests.post(f'{BASE}/api/auth/register', json={
    'display_name': f'test_{tag}',
    'email': f'test_{tag}@test.com',
    'password': 'Password123',
    'role': 'member',
    'user_type': 'freelancer'
})
test('Register user', r.status_code == 201, str(r.status_code))
user1 = r.json().get('user', {})
token1 = r.json().get('access_token', '')
refresh_token1 = r.json().get('refresh_token', '')
user1_id = user1.get('id')
headers1 = {'Authorization': f'Bearer {token1}'}

# 2. Register second user
r = requests.post(f'{BASE}/api/auth/register', json={
    'display_name': f'user2_{tag}',
    'email': f'user2_{tag}@test.com',
    'password': 'Password123',
    'role': 'member',
    'user_type': 'student'
})
test('Register user2', r.status_code == 201, str(r.status_code))
user2 = r.json().get('user', {})
token2 = r.json().get('access_token', '')
user2_id = user2.get('id')
headers2 = {'Authorization': f'Bearer {token2}'}

# 3. Register guest
r = requests.post(f'{BASE}/api/auth/register', json={
    'display_name': f'guest_{tag}',
    'email': f'guest_{tag}@test.com',
    'password': 'Password123',
    'role': 'guest'
})
test('Register guest', r.status_code == 201, str(r.status_code))
guest = r.json().get('user', {})
token_guest = r.json().get('access_token', '')
guest_id = guest.get('id')
headers_guest = {'Authorization': f'Bearer {token_guest}'}

# 3b. Register user3 (will NOT be added to any project — used for non-member tests)
r = requests.post(f'{BASE}/api/auth/register', json={
    'display_name': f'user3_{tag}',
    'email': f'user3_{tag}@test.com',
    'password': 'Password123',
    'role': 'member'
})
test('Register user3', r.status_code == 201, str(r.status_code))
user3 = r.json().get('user', {})
user3_id = user3.get('id')

# 4. Login
r = requests.post(f'{BASE}/api/auth/login', json={
    'email': f'test_{tag}@test.com',
    'password': 'Password123'
})
test('Login', r.status_code == 200, str(r.status_code))
refresh_token_login = r.json().get('refresh_token', '')

# 5. Login wrong password
r = requests.post(f'{BASE}/api/auth/login', json={
    'email': f'test_{tag}@test.com',
    'password': 'wrongpassword'
})
test('Login wrong pass', r.status_code == 401, str(r.status_code))

# 6. GET /me
r = requests.get(f'{BASE}/api/auth/me', headers=headers1)
test('GET /me', r.status_code == 200, str(r.status_code))

# 7. GET /me no token
r = requests.get(f'{BASE}/api/auth/me')
test('GET /me no token', r.status_code == 401, str(r.status_code))

# 8. Duplicate display_name
r = requests.post(f'{BASE}/api/auth/register', json={
    'display_name': f'test_{tag}',
    'email': f'new_{tag}@test.com',
    'password': 'Password123'
})
test('Dup display_name', r.status_code == 409, str(r.status_code))

# 9. Duplicate email
r = requests.post(f'{BASE}/api/auth/register', json={
    'display_name': f'new_{tag}',
    'email': f'test_{tag}@test.com',
    'password': 'Password123'
})
test('Dup email', r.status_code == 409, str(r.status_code))

# 10. Bad email format
r = requests.post(f'{BASE}/api/auth/register', json={
    'display_name': f'bad_{tag}',
    'email': 'notanemail',
    'password': 'Password123'
})
test('Bad email format', r.status_code == 400, str(r.status_code))

# 11. Short password
r = requests.post(f'{BASE}/api/auth/register', json={
    'display_name': f'short_{tag}',
    'email': f'short_{tag}@test.com',
    'password': 'abc'
})
test('Short password <8', r.status_code == 400, str(r.status_code))

# 12. Invalid user_type
r = requests.post(f'{BASE}/api/auth/register', json={
    'display_name': f'inv_{tag}',
    'email': f'inv_{tag}@test.com',
    'password': 'Password123',
    'user_type': 'hacker'
})
test('Invalid user_type', r.status_code == 400, str(r.status_code))

# 13. Missing required fields
r = requests.post(f'{BASE}/api/auth/register', json={})
test('Missing fields', r.status_code == 400, str(r.status_code))

# 13b. Password complexity — no uppercase letter
r = requests.post(f'{BASE}/api/auth/register', json={
    'display_name': f'noup_{tag}',
    'email': f'noup_{tag}@test.com',
    'password': 'newpass123'
})
test('Password no uppercase', r.status_code == 400, str(r.status_code))

# 13c. Password complexity — no digit
r = requests.post(f'{BASE}/api/auth/register', json={
    'display_name': f'nodig_{tag}',
    'email': f'nodig_{tag}@test.com',
    'password': 'NewPassword'
})
test('Password no digit', r.status_code == 400, str(r.status_code))

# 13d. GET /api/health
r = requests.get(f'{BASE}/api/health')
test('Health check', r.status_code == 200 and r.json().get('status') == 'ok', str(r.status_code))

# 13e. POST /api/auth/refresh — use refresh token from register
r = requests.post(f'{BASE}/api/auth/refresh',
                  headers={'Authorization': f'Bearer {refresh_token1}'})
test('Refresh token', r.status_code == 200 and 'access_token' in r.json(), str(r.status_code))

# 13f. Refresh with access token should fail
r = requests.post(f'{BASE}/api/auth/refresh',
                  headers={'Authorization': f'Bearer {token1}'})
test('Refresh with access token fails', r.status_code == 422, str(r.status_code))


# =================== PROJECTS ===================

# 14. Create project
r = requests.post(f'{BASE}/api/projects', headers=headers1, json={
    'name': f'Project_{tag}',
    'description': 'Test project',
    'status': 'planned',
    'start_date': '2026-01-01',
    'end_date': '2026-12-31'
})
test('Create project', r.status_code == 201, f'{r.status_code} {r.text[:100]}')
project = r.json().get('project', {})
project_id = project.get('id')

# 15. Create project no auth
r = requests.post(f'{BASE}/api/projects', json={'name': 'Test'})
test('Create proj no auth', r.status_code == 401, str(r.status_code))

# 16. Create project no name
r = requests.post(f'{BASE}/api/projects', headers=headers1, json={'description': 'no name'})
test('Create proj no name', r.status_code == 400, str(r.status_code))

# 16b. Create project end_date before start_date → 400
r = requests.post(f'{BASE}/api/projects', headers=headers1, json={
    'name': f'BadDates_{tag}',
    'start_date': '2026-12-31',
    'end_date': '2026-01-01'
})
test('Create proj bad dates', r.status_code == 400, f'{r.status_code} {r.text[:80]}')

# 17. Get my projects
r = requests.get(f'{BASE}/api/projects', headers=headers1)
test('Get my projects', r.status_code == 200, str(r.status_code))
data = r.json()
test('Projects has pagination', 'total' in data and 'pages' in data, str(list(data.keys())))

# 18. Get project by ID
r = requests.get(f'{BASE}/api/projects/{project_id}', headers=headers1)
test('Get project by ID', r.status_code == 200, str(r.status_code))

# 19. User2 can't see user1's project -> 403
r = requests.get(f'{BASE}/api/projects/{project_id}', headers=headers2)
test('Non-member get proj', r.status_code == 403, str(r.status_code))

# 20. Update project
r = requests.put(f'{BASE}/api/projects/{project_id}', headers=headers1, json={
    'name': f'Updated_{tag}',
    'status': 'active'
})
test('Update project', r.status_code == 200, str(r.status_code))

# 21. Update project bad status
r = requests.put(f'{BASE}/api/projects/{project_id}', headers=headers1, json={
    'status': 'invalid_status'
})
test('Update bad status', r.status_code == 400, str(r.status_code))

# 22. Update progress
r = requests.patch(f'{BASE}/api/projects/{project_id}/progress', headers=headers1, json={
    'progress': 50
})
test('Update progress', r.status_code == 200, str(r.status_code))

# 23. Update progress bad value
r = requests.patch(f'{BASE}/api/projects/{project_id}/progress', headers=headers1, json={
    'progress': 150
})
test('Progress bad val', r.status_code == 400, str(r.status_code))

# 24. Add member
r = requests.post(f'{BASE}/api/projects/{project_id}/members', headers=headers1, json={
    'user_id': user2_id,
    'role': 'member'
})
test('Add member', r.status_code == 201, f'{r.status_code} {r.text[:120]}')

# 25. Add member duplicate
r = requests.post(f'{BASE}/api/projects/{project_id}/members', headers=headers1, json={
    'user_id': user2_id,
    'role': 'member'
})
test('Add member dup', r.status_code == 400, str(r.status_code))

# 25b. GET /api/projects/<id>/members
r = requests.get(f'{BASE}/api/projects/{project_id}/members', headers=headers1)
data = r.json()
test('GET project members', r.status_code == 200 and data.get('total', 0) >= 2,
     f'{r.status_code} total={data.get("total")}')

# 26. User2 can now see project (as member)
r = requests.get(f'{BASE}/api/projects/{project_id}', headers=headers2)
test('Member can see proj', r.status_code == 200, str(r.status_code))

# 27. Search projects
r = requests.get(f'{BASE}/api/projects?search=Updated', headers=headers1)
total = r.json().get('total', 0)
test('Search projects', r.status_code == 200 and total > 0, f'{r.status_code} total={total}')

# 28. Filter by status
r = requests.get(f'{BASE}/api/projects?status=active', headers=headers1)
test('Filter by status', r.status_code == 200, str(r.status_code))

# 29. Non-existent project
r = requests.get(f'{BASE}/api/projects/{uuid.uuid4()}', headers=headers1)
test('Non-existent project', r.status_code == 404, str(r.status_code))


# =================== TASKS ===================

# 30. Create task
r = requests.post(f'{BASE}/api/tasks', headers=headers1, json={
    'title': f'Task_{tag}',
    'description': 'Test task',
    'status': 'pending',
    'priority': 'high',
    'project_id': project_id,
    'assigned_to': user2_id,
    'due_date': '2026-06-30'
})
test('Create task', r.status_code == 201, f'{r.status_code}')
task = r.json().get('task', {})
task_id = task.get('id')

# 30b. Create task invalid priority → 400
r = requests.post(f'{BASE}/api/tasks', headers=headers1, json={
    'title': 'Bad priority task',
    'project_id': project_id,
    'priority': 'super_high'
})
test('Create task bad priority', r.status_code == 400, f'{r.status_code} {r.text[:80]}')

# 30c. Create task assigned_to non-member → 400
r = requests.post(f'{BASE}/api/tasks', headers=headers1, json={
    'title': 'Non-member task',
    'project_id': project_id,
    'assigned_to': user3_id
})
test('Create task non-member', r.status_code == 400, f'{r.status_code} {r.text[:80]}')

# 31. Create task - member can't
r = requests.post(f'{BASE}/api/tasks', headers=headers2, json={
    'title': 'Member task',
    'project_id': project_id
})
test('Member cant create task', r.status_code == 403, str(r.status_code))

# 32. Get tasks by project
r = requests.get(f'{BASE}/api/tasks?project_id={project_id}', headers=headers1)
total = r.json().get('total', 0)
test('Get tasks by project', r.status_code == 200 and total >= 1, f'{r.status_code} total={total}')

# 33. Get single task
r = requests.get(f'{BASE}/api/tasks/{task_id}', headers=headers1)
test('Get task by ID', r.status_code == 200, str(r.status_code))

# 34. Member can view task
r = requests.get(f'{BASE}/api/tasks/{task_id}', headers=headers2)
test('Member can view task', r.status_code == 200, str(r.status_code))

# 35. Update task status (member can)
r = requests.patch(f'{BASE}/api/tasks/{task_id}/status', headers=headers2, json={
    'status': 'in_progress'
})
test('Member update status', r.status_code == 200, str(r.status_code))

# 36. Update task status invalid
r = requests.patch(f'{BASE}/api/tasks/{task_id}/status', headers=headers1, json={
    'status': 'invalid'
})
test('Bad task status', r.status_code == 400, str(r.status_code))

# 37. Update task (owner)
r = requests.put(f'{BASE}/api/tasks/{task_id}', headers=headers1, json={
    'title': f'Updated_Task_{tag}',
    'priority': 'low'
})
test('Update task', r.status_code == 200, str(r.status_code))

# 37b. Update task invalid priority → 400
r = requests.put(f'{BASE}/api/tasks/{task_id}', headers=headers1, json={
    'priority': 'urgent'
})
test('Update task bad priority', r.status_code == 400, f'{r.status_code} {r.text[:80]}')

# 37c. Update task assigned_to non-member → 400
r = requests.put(f'{BASE}/api/tasks/{task_id}', headers=headers1, json={
    'assigned_to': user3_id
})
test('Update task non-member', r.status_code == 400, f'{r.status_code} {r.text[:80]}')

# 38. Update task (member can't)
r = requests.put(f'{BASE}/api/tasks/{task_id}', headers=headers2, json={
    'title': 'Nope'
})
test('Member cant update task', r.status_code == 403, str(r.status_code))

# 39. Filter tasks by status
r = requests.get(f'{BASE}/api/tasks?project_id={project_id}&status=in_progress', headers=headers1)
total = r.json().get('total', 0)
test('Filter task by status', r.status_code == 200 and total >= 1, f'{r.status_code} total={total}')

# 40. Filter tasks by priority
r = requests.get(f'{BASE}/api/tasks?project_id={project_id}&priority=low', headers=headers1)
test('Filter task by priority', r.status_code == 200, f'{r.status_code} total={r.json().get("total")}')

# 41. Get tasks missing project_id
r = requests.get(f'{BASE}/api/tasks', headers=headers1)
test('Tasks no project_id', r.status_code == 400, str(r.status_code))


# =================== GUEST RBAC ===================

# 42. Add guest as member
r = requests.post(f'{BASE}/api/projects/{project_id}/members', headers=headers1, json={
    'user_id': guest_id,
    'role': 'member'
})
test('Add guest member', r.status_code == 201, str(r.status_code))

# 43. Guest can view project
r = requests.get(f'{BASE}/api/projects/{project_id}', headers=headers_guest)
test('Guest can view proj', r.status_code == 200, str(r.status_code))

# 44. Guest can view task
r = requests.get(f'{BASE}/api/tasks/{task_id}', headers=headers_guest)
test('Guest can view task', r.status_code == 200, str(r.status_code))

# 45. Guest can't update task status
r = requests.patch(f'{BASE}/api/tasks/{task_id}/status', headers=headers_guest, json={
    'status': 'done'
})
test('Guest cant update status', r.status_code == 403, str(r.status_code))

# 46. Guest can't update progress
r = requests.patch(f'{BASE}/api/projects/{project_id}/progress', headers=headers_guest, json={
    'progress': 80
})
test('Guest cant update prog', r.status_code == 403, str(r.status_code))

# 47. Guest can't create task
r = requests.post(f'{BASE}/api/tasks', headers=headers_guest, json={
    'title': 'Guest task',
    'project_id': project_id
})
test('Guest cant create task', r.status_code == 403, str(r.status_code))


# =================== USERS ===================

# 48. Get profile
r = requests.get(f'{BASE}/api/users/profile', headers=headers1)
test('Get user profile', r.status_code == 200, str(r.status_code))
profile = r.json().get('user', {})
test('Profile has display_name', 'display_name' in profile, str(list(profile.keys())))
test('Profile has user_type', 'user_type' in profile, str(profile.get('user_type')))

# 51. Get profile no auth
r = requests.get(f'{BASE}/api/users/profile')
test('Profile no auth', r.status_code == 401, str(r.status_code))

# 51b. PUT /api/users/profile — update display_name and full_name
r = requests.put(f'{BASE}/api/users/profile', headers=headers1, json={
    'display_name': f'updated_{tag}',
    'full_name': 'Test User Full Name',
    'user_type': 'employee'
})
test('Update profile', r.status_code == 200, str(r.status_code))
updated_user = r.json().get('user', {})
test('Profile name updated', updated_user.get('display_name') == f'updated_{tag}',
     updated_user.get('display_name'))
test('Profile user_type updated', updated_user.get('user_type') == 'employee',
     updated_user.get('user_type'))

# 51c. PUT /api/users/profile — invalid user_type → 400
r = requests.put(f'{BASE}/api/users/profile', headers=headers1, json={
    'user_type': 'hacker'
})
test('Update profile bad type', r.status_code == 400, str(r.status_code))

# 51d. PUT /api/users/profile — duplicate display_name → 409
r = requests.put(f'{BASE}/api/users/profile', headers=headers1, json={
    'display_name': f'user2_{tag}'
})
test('Update profile dup name', r.status_code == 409, str(r.status_code))


# =================== LOGS ===================

# 52. Get my logs
r = requests.get(f'{BASE}/api/logs/my', headers=headers1)
total = r.json().get('total', 0)
test('Get my logs', r.status_code == 200 and total > 0, f'{r.status_code} total={total}')

# 53. Get all logs (non-admin -> 403)
r = requests.get(f'{BASE}/api/logs/all', headers=headers1)
test('All logs non-admin', r.status_code == 403, str(r.status_code))


# =================== CLEANUP ===================

# 54. DELETE /api/projects/<id>/members/<user_id> — remove guest from project
r = requests.delete(f'{BASE}/api/projects/{project_id}/members/{guest_id}', headers=headers1)
test('Remove member (guest)', r.status_code == 200, str(r.status_code))

# 54b. Remove owner should fail → 400
project_owner_id = user1_id
r = requests.delete(f'{BASE}/api/projects/{project_id}/members/{project_owner_id}', headers=headers1)
test('Remove owner fails', r.status_code == 400, str(r.status_code))

# 55. Delete task (member can't)
r = requests.delete(f'{BASE}/api/tasks/{task_id}', headers=headers2)
test('Member cant del task', r.status_code == 403, str(r.status_code))

# 55. Delete task (owner)
r = requests.delete(f'{BASE}/api/tasks/{task_id}', headers=headers1)
test('Delete task owner', r.status_code == 200, str(r.status_code))

# 56. Delete already deleted task -> 404
r = requests.delete(f'{BASE}/api/tasks/{task_id}', headers=headers1)
test('Delete non-existent task', r.status_code == 404, str(r.status_code))

# 57. Delete project (member can't)
r = requests.delete(f'{BASE}/api/projects/{project_id}', headers=headers2)
test('Member cant del proj', r.status_code == 403, str(r.status_code))

# 58. Delete project (owner)
r = requests.delete(f'{BASE}/api/projects/{project_id}', headers=headers1)
test('Delete project owner', r.status_code == 200, str(r.status_code))


# =================== SUMMARY ===================
print()
passed = sum(1 for _, p, _ in results if p)
failed = sum(1 for _, p, _ in results if not p)
print(f'TOTAL: {passed}/{len(results)} passed, {failed} failed')
if failed:
    print('\nFAILURES:')
    for name, p, detail in results:
        if not p:
            print(f'  - {name}: {detail}')
