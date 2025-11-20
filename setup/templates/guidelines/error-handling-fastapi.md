# Error Handling - {{REPO_NAME}}

**Repository:** {{REPO_NAME}}
**Tech Stack:** Python + FastAPI
**Last Updated:** {{DATE}}

---

## Overview

This document defines error handling patterns for the {{REPO_NAME}} FastAPI backend. Consistent error handling improves API reliability and debugging.

---

## Error Categories

### Client Errors (4xx)
- 400 Bad Request - Invalid input
- 401 Unauthorized - Authentication required
- 403 Forbidden - Insufficient permissions
- 404 Not Found - Resource doesn't exist
- 422 Unprocessable Entity - Validation errors

### Server Errors (5xx)
- 500 Internal Server Error - Unexpected errors
- 503 Service Unavailable - External service down

---

## HTTP Exception Handling

### Raising HTTP Exceptions
```python
from fastapi import HTTPException, status

@router.get("/users/{user_id}")
async def get_user(user_id: int):
    user = await user_service.get_user(user_id)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User with id {user_id} not found"
        )

    return user
```

### Detailed Error Responses
```python
@router.post("/users")
async def create_user(user_data: UserCreate):
    existing_user = await user_service.get_by_email(user_data.email)

    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "message": "User already exists",
                "field": "email",
                "value": user_data.email
            }
        )

    return await user_service.create_user(user_data)
```

---

## Custom Exceptions

### Define Custom Exceptions
```python
# app/exceptions.py
class AppException(Exception):
    """Base exception for application errors"""
    def __init__(self, message: str, status_code: int = 500):
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)


class ResourceNotFoundError(AppException):
    def __init__(self, resource: str, resource_id: any):
        message = f"{resource} with id {resource_id} not found"
        super().__init__(message, status_code=404)


class ValidationError(AppException):
    def __init__(self, field: str, message: str):
        self.field = field
        super().__init__(f"Validation error on {field}: {message}", status_code=422)


class AuthenticationError(AppException):
    def __init__(self, message: str = "Authentication failed"):
        super().__init__(message, status_code=401)


class AuthorizationError(AppException):
    def __init__(self, message: str = "Insufficient permissions"):
        super().__init__(message, status_code=403)
```

### Register Exception Handlers
```python
# app/main.py
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from app.exceptions import AppException, ResourceNotFoundError

app = FastAPI()

@app.exception_handler(AppException)
async def app_exception_handler(request: Request, exc: AppException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": exc.__class__.__name__,
            "message": exc.message,
            "path": str(request.url)
        }
    )

@app.exception_handler(ResourceNotFoundError)
async def not_found_handler(request: Request, exc: ResourceNotFoundError):
    return JSONResponse(
        status_code=404,
        content={
            "error": "ResourceNotFound",
            "message": exc.message
        }
    )
```

### Using Custom Exceptions
```python
# app/services/user_service.py
from app.exceptions import ResourceNotFoundError, ValidationError

class UserService:
    async def get_user(self, user_id: int):
        user = await self.repo.get_by_id(user_id)
        if not user:
            raise ResourceNotFoundError("User", user_id)
        return user

    async def update_email(self, user_id: int, new_email: str):
        if not is_valid_email(new_email):
            raise ValidationError("email", "Invalid email format")

        existing = await self.repo.get_by_email(new_email)
        if existing and existing.id != user_id:
            raise ValidationError("email", "Email already in use")

        return await self.repo.update(user_id, email=new_email)
```

---

## Validation Errors

### Pydantic Validation
```python
from pydantic import BaseModel, Field, validator, ValidationError

class UserCreate(BaseModel):
    email: str = Field(..., regex=r'^\S+@\S+\.\S+$')
    age: int = Field(..., ge=0, le=150)
    password: str = Field(..., min_length=8)

    @validator('password')
    def validate_password_strength(cls, v):
        if not any(char.isdigit() for char in v):
            raise ValueError('Password must contain at least one digit')
        if not any(char.isupper() for char in v):
            raise ValueError('Password must contain at least one uppercase letter')
        return v
```

### Custom Validation Error Handler
```python
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = []
    for error in exc.errors():
        errors.append({
            "field": ".".join(str(loc) for loc in error["loc"][1:]),
            "message": error["msg"],
            "type": error["type"]
        })

    return JSONResponse(
        status_code=422,
        content={
            "error": "ValidationError",
            "message": "Request validation failed",
            "errors": errors
        }
    )
```

---

## Database Errors

### Handling SQLAlchemy Errors
```python
from sqlalchemy.exc import IntegrityError, SQLAlchemyError

async def create_user(user_data: UserCreate, db: AsyncSession):
    try:
        user = User(**user_data.dict())
        db.add(user)
        await db.commit()
        await db.refresh(user)
        return user
    except IntegrityError as e:
        await db.rollback()
        if 'unique constraint' in str(e).lower():
            raise ValidationError("email", "Email already exists")
        raise AppException("Database integrity error", 500)
    except SQLAlchemyError as e:
        await db.rollback()
        logger.error(f"Database error: {e}")
        raise AppException("Database operation failed", 500)
```

### Transaction Management
```python
from contextlib import asynccontextmanager

@asynccontextmanager
async def transaction(db: AsyncSession):
    try:
        yield db
        await db.commit()
    except Exception as e:
        await db.rollback()
        logger.error(f"Transaction rolled back: {e}")
        raise
```

---

## Dependency Errors

### Dependency with Error Handling
```python
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    auth_service: AuthService = Depends()
) -> User:
    try:
        user = await auth_service.verify_token(credentials.credentials)
        if not user:
            raise AuthenticationError("Invalid token")
        return user
    except Exception as e:
        logger.error(f"Authentication error: {e}")
        raise AuthenticationError()
```

---

## Logging Errors

### Structured Logging
```python
# app/utils/logger.py
import logging
import json
from datetime import datetime

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
        }

        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)

        return json.dumps(log_data)

# Configure logger
logger = logging.getLogger("app")
handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logger.addHandler(handler)
logger.setLevel(logging.INFO)
```

### Using Logger
```python
from app.utils.logger import logger

async def process_payment(payment_data: PaymentCreate):
    try:
        result = await payment_service.process(payment_data)
        logger.info(f"Payment processed successfully: {result.id}")
        return result
    except PaymentError as e:
        logger.error(f"Payment failed: {e.message}", extra={
            "payment_id": payment_data.id,
            "amount": payment_data.amount,
            "error_code": e.code
        })
        raise
    except Exception as e:
        logger.exception("Unexpected error processing payment")
        raise AppException("Payment processing failed", 500)
```

---

## External Service Errors

### HTTP Client with Retry
```python
import httpx
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=10)
)
async def fetch_external_data(url: str):
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(url, timeout=10.0)
            response.raise_for_status()
            return response.json()
        except httpx.HTTPStatusError as e:
            logger.error(f"HTTP error from external service: {e.response.status_code}")
            raise AppException(f"External service error: {e.response.status_code}", 503)
        except httpx.TimeoutException:
            logger.error("External service timeout")
            raise AppException("External service timeout", 503)
        except Exception as e:
            logger.exception("Unexpected error calling external service")
            raise AppException("External service unavailable", 503)
```

---

## Graceful Degradation

### Circuit Breaker Pattern
```python
from datetime import datetime, timedelta

class CircuitBreaker:
    def __init__(self, failure_threshold: int = 5, timeout: int = 60):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.failures = 0
        self.last_failure_time = None
        self.state = "closed"  # closed, open, half-open

    async def call(self, func, *args, **kwargs):
        if self.state == "open":
            if datetime.now() - self.last_failure_time > timedelta(seconds=self.timeout):
                self.state = "half-open"
            else:
                raise AppException("Service temporarily unavailable", 503)

        try:
            result = await func(*args, **kwargs)
            if self.state == "half-open":
                self.state = "closed"
                self.failures = 0
            return result
        except Exception as e:
            self.failures += 1
            self.last_failure_time = datetime.now()

            if self.failures >= self.failure_threshold:
                self.state = "open"

            raise
```

---

## Error Response Standards

### Consistent Error Format
```python
from pydantic import BaseModel
from typing import Optional, List

class ErrorDetail(BaseModel):
    field: Optional[str] = None
    message: str
    code: Optional[str] = None

class ErrorResponse(BaseModel):
    error: str  # Error type/class
    message: str  # Human-readable message
    details: Optional[List[ErrorDetail]] = None
    path: Optional[str] = None
    timestamp: str

# Example response:
{
  "error": "ValidationError",
  "message": "Request validation failed",
  "details": [
    {
      "field": "email",
      "message": "Email already exists",
      "code": "duplicate_email"
    }
  ],
  "path": "/api/v1/users",
  "timestamp": "2025-11-19T10:30:00Z"
}
```

---

## Monitoring & Alerting

### Health Check Endpoint
```python
@app.get("/health")
async def health_check():
    try:
        # Check database
        await db.execute("SELECT 1")

        # Check external services
        await check_external_service()

        return {"status": "healthy"}
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        raise HTTPException(status_code=503, detail="Service unhealthy")
```

---

## Best Practices

### ✅ Do
- Use appropriate HTTP status codes
- Provide clear, actionable error messages
- Log errors with context
- Handle database errors gracefully
- Implement retry logic for transient failures
- Use custom exceptions for domain errors
- Validate input at API boundary
- Return consistent error response format

### ❌ Don't
- Don't expose sensitive information in errors
- Don't log sensitive data (passwords, tokens)
- Don't ignore exceptions silently
- Don't use generic exceptions for everything
- Don't return stack traces to clients
- Don't forget to rollback transactions on error

---

## Related Guidelines

- **Architectural Principles:** See `architectural-principles.md` for service layer patterns
- **Testing:** See `testing-standards.md` for testing error scenarios
- **Documentation Standards:** See `../global/documentation-standards.md`

---

**Note:** This is a living document. Update as error handling patterns evolve.
