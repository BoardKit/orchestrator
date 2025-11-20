# Testing Standards - {{REPO_NAME}}

**Repository:** {{REPO_NAME}}
**Tech Stack:** Python + FastAPI + pytest
**Last Updated:** {{DATE}}

---

## Overview

This document defines testing standards for the {{REPO_NAME}} FastAPI backend. Consistent testing practices ensure code quality and prevent regressions.

---

## Testing Tools

- **pytest:** Test framework and runner
- **pytest-asyncio:** Async test support
- **httpx:** Async HTTP client for API testing
- **pytest-cov:** Coverage reporting
- **factory-boy / faker:** Test data generation

---

## Test Structure

### File Organization
```
tests/
├── __init__.py
├── conftest.py          # Shared fixtures
├── test_api/
│   ├── __init__.py
│   ├── test_users.py
│   └── test_auth.py
├── test_services/
│   ├── __init__.py
│   └── test_user_service.py
└── test_repositories/
    ├── __init__.py
    └── test_user_repository.py
```

### Test File Naming
- Test files: `test_*.py` or `*_test.py`
- Test functions: `test_*`
- Test classes: `Test*`

---

## Fixtures

### Common Fixtures (conftest.py)
```python
# tests/conftest.py
import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

from app.main import app
from app.database import Base, get_db
from app.config import settings

# Test database
TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"

@pytest.fixture
async def db_session():
    """Create a fresh database for each test"""
    engine = create_async_engine(TEST_DATABASE_URL)

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async_session = sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )

    async with async_session() as session:
        yield session

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

    await engine.dispose()


@pytest.fixture
async def client(db_session):
    """Create test client with database override"""
    async def override_get_db():
        yield db_session

    app.dependency_overrides[get_db] = override_get_db

    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac

    app.dependency_overrides.clear()


@pytest.fixture
def sample_user_data():
    """Sample user data for testing"""
    return {
        "email": "test@example.com",
        "name": "Test User",
        "age": 30
    }
```

---

## API Testing

### Basic Endpoint Test
```python
# tests/test_api/test_users.py
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_create_user(client: AsyncClient, sample_user_data):
    """Test creating a new user"""
    response = await client.post("/api/v1/users", json=sample_user_data)

    assert response.status_code == 201
    data = response.json()
    assert data["email"] == sample_user_data["email"]
    assert data["name"] == sample_user_data["name"]
    assert "id" in data


@pytest.mark.asyncio
async def test_get_user(client: AsyncClient, sample_user_data):
    """Test retrieving a user"""
    # Create user first
    create_response = await client.post("/api/v1/users", json=sample_user_data)
    user_id = create_response.json()["id"]

    # Get user
    response = await client.get(f"/api/v1/users/{user_id}")

    assert response.status_code == 200
    assert response.json()["id"] == user_id


@pytest.mark.asyncio
async def test_get_nonexistent_user(client: AsyncClient):
    """Test getting a user that doesn't exist returns 404"""
    response = await client.get("/api/v1/users/99999")

    assert response.status_code == 404
    assert "not found" in response.json()["detail"].lower()
```

### Testing with Authentication
```python
@pytest.fixture
async def auth_token(client: AsyncClient):
    """Get authentication token"""
    response = await client.post(
        "/api/v1/auth/login",
        json={"email": "admin@example.com", "password": "admin123"}
    )
    return response.json()["access_token"]


@pytest.mark.asyncio
async def test_protected_endpoint(client: AsyncClient, auth_token):
    """Test endpoint that requires authentication"""
    headers = {"Authorization": f"Bearer {auth_token}"}
    response = await client.get("/api/v1/me", headers=headers)

    assert response.status_code == 200


@pytest.mark.asyncio
async def test_protected_endpoint_without_auth(client: AsyncClient):
    """Test protected endpoint returns 401 without token"""
    response = await client.get("/api/v1/me")

    assert response.status_code == 401
```

---

## Service Layer Testing

### Testing Business Logic
```python
# tests/test_services/test_user_service.py
import pytest
from app.services.user_service import UserService
from app.repositories.user_repository import UserRepository
from app.exceptions import ResourceNotFoundError

@pytest.mark.asyncio
async def test_create_user(db_session):
    """Test user creation through service layer"""
    repo = UserRepository(db_session)
    service = UserService(repo)

    user_data = {
        "email": "new@example.com",
        "name": "New User",
        "age": 25
    }

    user = await service.create_user(user_data)

    assert user.id is not None
    assert user.email == user_data["email"]


@pytest.mark.asyncio
async def test_get_user_not_found(db_session):
    """Test service raises exception for nonexistent user"""
    repo = UserRepository(db_session)
    service = UserService(repo)

    with pytest.raises(ResourceNotFoundError) as exc_info:
        await service.get_user(99999)

    assert "User" in str(exc_info.value)
    assert "99999" in str(exc_info.value)


@pytest.mark.asyncio
async def test_duplicate_email(db_session):
    """Test service prevents duplicate email addresses"""
    repo = UserRepository(db_session)
    service = UserService(repo)

    user_data = {"email": "duplicate@example.com", "name": "User", "age": 30}

    # Create first user
    await service.create_user(user_data)

    # Try to create second user with same email
    with pytest.raises(ValidationError) as exc_info:
        await service.create_user(user_data)

    assert "email" in str(exc_info.value).lower()
```

---

## Repository Layer Testing

### Testing Data Access
```python
# tests/test_repositories/test_user_repository.py
import pytest
from sqlalchemy.ext.asyncio import AsyncSession
from app.repositories.user_repository import UserRepository
from app.models.user import User

@pytest.mark.asyncio
async def test_create_user(db_session: AsyncSession):
    """Test creating a user in the database"""
    repo = UserRepository(db_session)

    user_data = {
        "email": "test@example.com",
        "name": "Test User",
        "age": 30
    }

    user = await repo.create(user_data)

    assert user.id is not None
    assert user.email == user_data["email"]


@pytest.mark.asyncio
async def test_get_by_id(db_session: AsyncSession):
    """Test retrieving user by ID"""
    repo = UserRepository(db_session)

    # Create user
    user = await repo.create({"email": "test@example.com", "name": "Test", "age": 30})

    # Retrieve user
    retrieved = await repo.get_by_id(user.id)

    assert retrieved is not None
    assert retrieved.id == user.id
    assert retrieved.email == user.email


@pytest.mark.asyncio
async def test_update_user(db_session: AsyncSession):
    """Test updating user data"""
    repo = UserRepository(db_session)

    # Create user
    user = await repo.create({"email": "test@example.com", "name": "Old Name", "age": 30})

    # Update user
    updated = await repo.update(user.id, name="New Name", age=31)

    assert updated.name == "New Name"
    assert updated.age == 31
    assert updated.email == user.email  # Unchanged


@pytest.mark.asyncio
async def test_delete_user(db_session: AsyncSession):
    """Test deleting a user"""
    repo = UserRepository(db_session)

    # Create user
    user = await repo.create({"email": "test@example.com", "name": "Test", "age": 30})
    user_id = user.id

    # Delete user
    await repo.delete(user_id)

    # Verify deletion
    deleted_user = await repo.get_by_id(user_id)
    assert deleted_user is None
```

---

## Parametrized Tests

### Testing Multiple Cases
```python
@pytest.mark.parametrize("email,expected_valid", [
    ("valid@example.com", True),
    ("also.valid@example.co.uk", True),
    ("invalid", False),
    ("@example.com", False),
    ("missing@", False),
])
def test_email_validation(email, expected_valid):
    """Test email validation with various inputs"""
    is_valid = validate_email(email)
    assert is_valid == expected_valid


@pytest.mark.parametrize("age,should_succeed", [
    (0, True),
    (18, True),
    (150, True),
    (-1, False),
    (151, False),
])
@pytest.mark.asyncio
async def test_age_validation(client: AsyncClient, age, should_succeed):
    """Test age validation at API level"""
    response = await client.post(
        "/api/v1/users",
        json={"email": "test@example.com", "name": "Test", "age": age}
    )

    if should_succeed:
        assert response.status_code == 201
    else:
        assert response.status_code == 422
```

---

## Mocking

### Mocking External Services
```python
from unittest.mock import AsyncMock, patch

@pytest.mark.asyncio
async def test_external_api_call():
    """Test function that calls external API"""
    mock_response = {"data": "test"}

    with patch('app.services.external_service.httpx.AsyncClient.get') as mock_get:
        mock_get.return_value.json = AsyncMock(return_value=mock_response)
        mock_get.return_value.status_code = 200

        result = await fetch_external_data()

        assert result == mock_response
        mock_get.assert_called_once()


@pytest.mark.asyncio
async def test_email_sending(db_session):
    """Test email is sent when user is created"""
    with patch('app.services.email_service.send_email') as mock_send:
        service = UserService(db_session)
        user = await service.create_user({
            "email": "test@example.com",
            "name": "Test",
            "age": 30
        })

        mock_send.assert_called_once_with(
            to=user.email,
            subject="Welcome!",
            body=pytest.anything
        )
```

---

## Test Factories

### Using factory_boy
```python
# tests/factories.py
import factory
from factory.fuzzy import FuzzyChoice, FuzzyInteger
from app.models.user import User

class UserFactory(factory.Factory):
    class Meta:
        model = User

    email = factory.Faker('email')
    name = factory.Faker('name')
    age = FuzzyInteger(18, 90)
    role = FuzzyChoice(['user', 'admin'])


# Usage in tests
@pytest.mark.asyncio
async def test_with_factory(db_session):
    """Test using factory-generated data"""
    user_data = UserFactory.build().__dict__
    repo = UserRepository(db_session)

    user = await repo.create(user_data)

    assert user.email == user_data["email"]
```

---

## Testing Exceptions

### Exception Handling Tests
```python
@pytest.mark.asyncio
async def test_service_handles_database_error(db_session):
    """Test service properly handles database errors"""
    repo = UserRepository(db_session)
    service = UserService(repo)

    # Force a database error
    with patch.object(repo, 'create', side_effect=SQLAlchemyError("DB Error")):
        with pytest.raises(AppException) as exc_info:
            await service.create_user({"email": "test@example.com"})

        assert exc_info.value.status_code == 500


@pytest.mark.asyncio
async def test_api_returns_proper_error_format(client: AsyncClient):
    """Test API returns consistent error format"""
    response = await client.get("/api/v1/users/invalid")

    assert response.status_code == 422
    data = response.json()
    assert "error" in data
    assert "message" in data
```

---

## Test Coverage

### Coverage Goals
- Statements: > 85%
- Branches: > 80%
- Functions: > 85%
- Lines: > 85%

### Running Coverage
```bash
pytest --cov=app --cov-report=html --cov-report=term
```

### Coverage Configuration
```ini
# pytest.ini
[tool:pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
asyncio_mode = auto

addopts =
    --cov=app
    --cov-report=term-missing
    --cov-report=html
    --cov-fail-under=85

[coverage:run]
source = app
omit =
    */tests/*
    */migrations/*
    */__init__.py
```

---

## Testing Best Practices

### ✅ Do
- Use descriptive test names
- Test one thing per test
- Use fixtures for shared setup
- Test edge cases and error conditions
- Mock external dependencies
- Use parametrize for similar tests
- Keep tests independent
- Clean up after tests

### ❌ Don't
- Don't test implementation details
- Don't make tests dependent on each other
- Don't skip error cases
- Don't use sleep() - use proper async patterns
- Don't ignore flaky tests
- Don't test third-party libraries

---

## Test Organization

### AAA Pattern
```python
def test_user_creation():
    # Arrange
    user_data = {"email": "test@example.com", "name": "Test", "age": 30}

    # Act
    user = create_user(user_data)

    # Assert
    assert user.email == user_data["email"]
```

### Descriptive Names
```python
# ❌ Bad
def test_user():
    pass

# ✅ Good
def test_create_user_with_valid_data_returns_user_object():
    pass
```

---

## Common Testing Patterns

### Testing Async Functions
```python
@pytest.mark.asyncio
async def test_async_function():
    result = await async_function()
    assert result is not None
```

### Testing Database Transactions
```python
@pytest.mark.asyncio
async def test_transaction_rollback(db_session):
    """Test transaction rolls back on error"""
    repo = UserRepository(db_session)

    try:
        async with db_session.begin():
            await repo.create({"email": "test@example.com"})
            raise Exception("Force rollback")
    except:
        pass

    # User should not exist due to rollback
    users = await repo.get_all()
    assert len(users) == 0
```

### Testing Pagination
```python
@pytest.mark.asyncio
async def test_list_users_pagination(client: AsyncClient):
    """Test API pagination"""
    # Create 25 users
    for i in range(25):
        await client.post("/api/v1/users", json={
            "email": f"user{i}@example.com",
            "name": f"User {i}",
            "age": 30
        })

    # Get first page
    response = await client.get("/api/v1/users?page=1&page_size=10")
    assert response.status_code == 200
    data = response.json()
    assert len(data["items"]) == 10
    assert data["total"] == 25
    assert data["page"] == 1
```

---

## Related Guidelines

- **Architectural Principles:** See `architectural-principles.md` for service/repository patterns
- **Error Handling:** See `error-handling.md` for exception patterns to test
- **Documentation Standards:** See `../global/documentation-standards.md`

---

**Note:** This is a living document. Update as testing practices evolve.
