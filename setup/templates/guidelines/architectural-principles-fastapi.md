# Architectural Principles - {{REPO_NAME}}

**Repository:** {{REPO_NAME}}
**Tech Stack:** Python + FastAPI
**Last Updated:** {{DATE}}

---

## Overview

This document defines architectural patterns and principles for the {{REPO_NAME}} FastAPI backend. Follow these guidelines to maintain consistency and code quality.

---

## Project Structure

```
{{REPO_NAME}}/
├── app/
│   ├── main.py              # FastAPI app initialization
│   ├── config.py            # Configuration and settings
│   ├── dependencies.py      # Dependency injection
│   ├── api/
│   │   ├── __init__.py
│   │   └── v1/              # API version 1
│   │       ├── __init__.py
│   │       ├── endpoints/   # Route handlers
│   │       └── schemas.py   # Pydantic schemas
│   ├── models/              # Database models
│   ├── services/            # Business logic
│   ├── repositories/        # Data access layer
│   └── utils/               # Utility functions
├── tests/                   # Test files
└── requirements.txt         # Dependencies
```

---

## Layered Architecture

### Layers (from top to bottom)

**API Layer** (`app/api/`)
- Route definitions and HTTP handling
- Request validation via Pydantic
- Response serialization
- Authentication/authorization

**Service Layer** (`app/services/`)
- Business logic and orchestration
- Coordinates between repositories
- Implements business rules
- No direct database access

**Repository Layer** (`app/repositories/`)
- Data access and persistence
- Database queries
- CRUD operations
- No business logic

**Model Layer** (`app/models/`)
- Database models (SQLAlchemy, etc.)
- Table definitions
- Relationships

---

## File Organization

### Endpoint Files
```python
# app/api/v1/endpoints/users.py
from fastapi import APIRouter, Depends, HTTPException
from app.services.user_service import UserService
from app.api.v1.schemas import UserCreate, UserResponse

router = APIRouter(prefix="/users", tags=["users"])

@router.post("/", response_model=UserResponse)
async def create_user(
    user_data: UserCreate,
    service: UserService = Depends()
):
    return await service.create_user(user_data)
```

### Service Files
```python
# app/services/user_service.py
from app.repositories.user_repository import UserRepository
from app.api.v1.schemas import UserCreate, UserUpdate

class UserService:
    def __init__(self, repo: UserRepository = Depends()):
        self.repo = repo

    async def create_user(self, user_data: UserCreate):
        # Business logic here
        return await self.repo.create(user_data)
```

### Repository Files
```python
# app/repositories/user_repository.py
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.user import User

class UserRepository:
    def __init__(self, db: AsyncSession = Depends()):
        self.db = db

    async def create(self, user_data):
        user = User(**user_data.dict())
        self.db.add(user)
        await self.db.commit()
        await self.db.refresh(user)
        return user
```

---

## Dependency Injection

Use FastAPI's dependency injection system:

```python
# app/dependencies.py
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import SessionLocal

async def get_db() -> AsyncSession:
    async with SessionLocal() as session:
        yield session

# Usage in endpoints
@router.get("/users/{user_id}")
async def get_user(
    user_id: int,
    db: AsyncSession = Depends(get_db)
):
    return await db.get(User, user_id)
```

---

## Request/Response Models

### Pydantic Schemas

**Request Models:**
```python
# app/api/v1/schemas.py
from pydantic import BaseModel, EmailStr, Field

class UserCreate(BaseModel):
    email: EmailStr
    name: str = Field(..., min_length=1, max_length=100)
    age: int = Field(..., ge=0, le=150)

class UserUpdate(BaseModel):
    name: str | None = None
    age: int | None = Field(None, ge=0, le=150)
```

**Response Models:**
```python
class UserResponse(BaseModel):
    id: int
    email: str
    name: str
    created_at: datetime

    class Config:
        from_attributes = True  # For ORM compatibility
```

---

## Database Patterns

### Async Database Operations
```python
# Always use async/await
async def get_users(db: AsyncSession) -> list[User]:
    result = await db.execute(select(User))
    return result.scalars().all()
```

### Transactions
```python
async def transfer_funds(
    from_id: int,
    to_id: int,
    amount: float,
    db: AsyncSession
):
    async with db.begin():
        # Operations here are in a transaction
        await deduct_balance(from_id, amount, db)
        await add_balance(to_id, amount, db)
```

---

## Error Handling

### HTTP Exceptions
```python
from fastapi import HTTPException, status

@router.get("/users/{user_id}")
async def get_user(user_id: int, service: UserService = Depends()):
    user = await service.get_user(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User {user_id} not found"
        )
    return user
```

### Custom Exceptions
```python
# app/exceptions.py
class UserNotFoundError(Exception):
    pass

# app/main.py
@app.exception_handler(UserNotFoundError)
async def user_not_found_handler(request, exc):
    return JSONResponse(
        status_code=404,
        content={"detail": str(exc)}
    )
```

---

## Authentication & Authorization

### JWT Authentication
```python
# app/dependencies.py
from fastapi.security import HTTPBearer
from app.services.auth_service import AuthService

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    auth_service: AuthService = Depends()
):
    return await auth_service.verify_token(credentials.credentials)
```

### Protected Endpoints
```python
@router.get("/me")
async def get_current_user_info(
    current_user: User = Depends(get_current_user)
):
    return current_user
```

---

## Configuration Management

### Settings with Pydantic
```python
# app/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    secret_key: str
    debug: bool = False

    class Config:
        env_file = ".env"

settings = Settings()
```

### Environment-Specific Config
```python
# .env.development
DATABASE_URL=sqlite:///./dev.db
DEBUG=true

# .env.production
DATABASE_URL=postgresql://...
DEBUG=false
```

---

## API Versioning

### URL-Based Versioning
```python
# app/api/v1/__init__.py
from fastapi import APIRouter
from app.api.v1.endpoints import users, items

router = APIRouter(prefix="/v1")
router.include_router(users.router)
router.include_router(items.router)

# app/main.py
app.include_router(api_v1.router, prefix="/api")
# Results in: /api/v1/users, /api/v1/items
```

---

## Background Tasks

### Using BackgroundTasks
```python
from fastapi import BackgroundTasks

def send_email(email: str, message: str):
    # Send email logic
    pass

@router.post("/signup")
async def signup(
    user: UserCreate,
    background_tasks: BackgroundTasks,
    service: UserService = Depends()
):
    user = await service.create_user(user)
    background_tasks.add_task(send_email, user.email, "Welcome!")
    return user
```

---

## Testing Strategy

### Dependency Overrides
```python
# tests/conftest.py
from app.dependencies import get_db

async def override_get_db():
    # Return test database session
    pass

app.dependency_overrides[get_db] = override_get_db
```

---

## Performance Considerations

### Database Connection Pooling
```python
# Use async connection pooling
engine = create_async_engine(
    DATABASE_URL,
    pool_size=20,
    max_overflow=10
)
```

### Response Caching
```python
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache

@router.get("/users")
@cache(expire=60)  # Cache for 60 seconds
async def list_users():
    return await user_service.get_all()
```

---

## Documentation

### OpenAPI/Swagger
Leverage FastAPI's automatic documentation:
```python
@router.post(
    "/users",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new user",
    description="Creates a new user with the provided information"
)
async def create_user(user: UserCreate):
    pass
```

---

## Related Guidelines

- **Error Handling:** See `error-handling.md` for FastAPI error patterns
- **Testing:** See `testing-standards.md` for pytest and FastAPI testing patterns
- **Documentation Standards:** See `../global/documentation-standards.md`

---

**Note:** This is a living document. Update as the architecture evolves.
