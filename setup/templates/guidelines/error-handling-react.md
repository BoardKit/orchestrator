# Error Handling - {{REPO_NAME}}

**Repository:** {{REPO_NAME}}
**Tech Stack:** React + TypeScript
**Last Updated:** {{DATE}}

---

## Overview

This document defines error handling patterns for the {{REPO_NAME}} React application. Consistent error handling improves user experience and debugging.

---

## Error Categories

### User-Facing Errors
- Form validation errors
- Network/API errors
- Permission/authentication errors
- Display user-friendly messages

### Developer Errors
- Runtime errors (bugs)
- Console warnings
- Log to error tracking service
- Should not crash the app

---

## Error Boundaries

### Basic Error Boundary
```typescript
// src/components/ErrorBoundary.tsx
import React, { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    // Log to error tracking service (e.g., Sentry)
    logErrorToService(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="error-fallback">
          <h2>Something went wrong</h2>
          <button onClick={() => window.location.reload()}>
            Reload Page
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}
```

### Usage
```typescript
// Wrap entire app
<ErrorBoundary>
  <App />
</ErrorBoundary>

// Wrap specific features
<ErrorBoundary fallback={<FeatureErrorFallback />}>
  <ComplexFeature />
</ErrorBoundary>
```

---

## API Error Handling

### API Service with Error Handling
```typescript
// src/services/api.ts
export class ApiError extends Error {
  constructor(
    public status: number,
    public message: string,
    public data?: any
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export async function apiRequest<T>(
  url: string,
  options?: RequestInit
): Promise<T> {
  try {
    const response = await fetch(url, options);

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new ApiError(
        response.status,
        errorData.message || response.statusText,
        errorData
      );
    }

    return await response.json();
  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }
    // Network error or JSON parse error
    throw new ApiError(0, 'Network error occurred', error);
  }
}
```

### Handling API Errors in Components
```typescript
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiRequest<User>(`/api/users/${userId}`)
      .then(setUser)
      .catch((err: ApiError) => {
        if (err.status === 404) {
          setError('User not found');
        } else if (err.status === 403) {
          setError('You do not have permission to view this user');
        } else if (err.status === 0) {
          setError('Network error. Please check your connection.');
        } else {
          setError('Failed to load user. Please try again.');
        }
        console.error('API error:', err);
      })
      .finally(() => setLoading(false));
  }, [userId]);

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message={error} />;
  if (!user) return null;

  return <UserCard user={user} />;
}
```

---

## Custom Error Hook

### useAsync Hook
```typescript
// src/hooks/useAsync.ts
import { useState, useEffect } from 'react';

interface AsyncState<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
}

export function useAsync<T>(
  asyncFunction: () => Promise<T>,
  dependencies: any[] = []
) {
  const [state, setState] = useState<AsyncState<T>>({
    data: null,
    loading: true,
    error: null,
  });

  useEffect(() => {
    let cancelled = false;

    setState({ data: null, loading: true, error: null });

    asyncFunction()
      .then((data) => {
        if (!cancelled) {
          setState({ data, loading: false, error: null });
        }
      })
      .catch((error) => {
        if (!cancelled) {
          setState({ data: null, loading: false, error });
        }
      });

    return () => {
      cancelled = true;
    };
  }, dependencies);

  return state;
}
```

### Usage
```typescript
function UserProfile({ userId }: { userId: string }) {
  const { data: user, loading, error } = useAsync(
    () => apiRequest<User>(`/api/users/${userId}`),
    [userId]
  );

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!user) return null;

  return <UserCard user={user} />;
}
```

---

## Form Validation Errors

### Controlled Form with Validation
```typescript
interface FormErrors {
  email?: string;
  password?: string;
}

function LoginForm() {
  const [values, setValues] = useState({ email: '', password: '' });
  const [errors, setErrors] = useState<FormErrors>({});

  const validate = (): boolean => {
    const newErrors: FormErrors = {};

    if (!values.email) {
      newErrors.email = 'Email is required';
    } else if (!/\S+@\S+\.\S+/.test(values.email)) {
      newErrors.email = 'Email is invalid';
    }

    if (!values.password) {
      newErrors.password = 'Password is required';
    } else if (values.password.length < 8) {
      newErrors.password = 'Password must be at least 8 characters';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validate()) return;

    try {
      await login(values);
    } catch (error) {
      if (error instanceof ApiError && error.status === 401) {
        setErrors({ password: 'Invalid email or password' });
      } else {
        alert('Login failed. Please try again.');
      }
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        value={values.email}
        onChange={(e) => setValues({ ...values, email: e.target.value })}
      />
      {errors.email && <span className="error">{errors.email}</span>}

      <input
        type="password"
        value={values.password}
        onChange={(e) => setValues({ ...values, password: e.target.value })}
      />
      {errors.password && <span className="error">{errors.password}</span>}

      <button type="submit">Login</button>
    </form>
  );
}
```

---

## Toast Notifications for Errors

### Toast Context
```typescript
// src/contexts/ToastContext.tsx
import { createContext, useContext, useState } from 'react';

interface Toast {
  id: string;
  type: 'success' | 'error' | 'info';
  message: string;
}

interface ToastContextType {
  showToast: (type: Toast['type'], message: string) => void;
}

const ToastContext = createContext<ToastContextType | undefined>(undefined);

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);

  const showToast = (type: Toast['type'], message: string) => {
    const id = Date.now().toString();
    setToasts((prev) => [...prev, { id, type, message }]);

    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 5000);
  };

  return (
    <ToastContext.Provider value={{ showToast }}>
      {children}
      <div className="toast-container">
        {toasts.map((toast) => (
          <div key={toast.id} className={`toast toast-${toast.type}`}>
            {toast.message}
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  );
}

export function useToast() {
  const context = useContext(ToastContext);
  if (!context) throw new Error('useToast must be used within ToastProvider');
  return context;
}
```

### Usage
```typescript
function UpdateUserButton({ userId }: { userId: string }) {
  const { showToast } = useToast();

  const handleUpdate = async () => {
    try {
      await updateUser(userId, { name: 'New Name' });
      showToast('success', 'User updated successfully');
    } catch (error) {
      showToast('error', 'Failed to update user');
      console.error(error);
    }
  };

  return <button onClick={handleUpdate}>Update User</button>;
}
```

---

## Error Logging

### Console Logging
```typescript
// src/utils/logger.ts
export const logger = {
  error: (message: string, error?: Error, context?: any) => {
    console.error(`[ERROR] ${message}`, {
      error: error?.message,
      stack: error?.stack,
      context,
      timestamp: new Date().toISOString(),
    });
  },

  warn: (message: string, context?: any) => {
    console.warn(`[WARN] ${message}`, { context, timestamp: new Date().toISOString() });
  },

  info: (message: string, context?: any) => {
    console.log(`[INFO] ${message}`, { context, timestamp: new Date().toISOString() });
  },
};
```

### Error Tracking Service
```typescript
// src/utils/errorTracking.ts
export function logErrorToService(error: Error, errorInfo?: any) {
  // Example: Sentry
  if (process.env.NODE_ENV === 'production') {
    // Sentry.captureException(error, { extra: errorInfo });
  }

  // Always log to console in development
  if (process.env.NODE_ENV === 'development') {
    console.error('Error logged:', error, errorInfo);
  }
}
```

---

## Error Message Components

### Reusable Error Display
```typescript
// src/components/ErrorMessage.tsx
interface ErrorMessageProps {
  message?: string;
  error?: Error;
  onRetry?: () => void;
}

export function ErrorMessage({ message, error, onRetry }: ErrorMessageProps) {
  const displayMessage = message || error?.message || 'An error occurred';

  return (
    <div className="error-message">
      <span className="error-icon">⚠️</span>
      <p>{displayMessage}</p>
      {onRetry && (
        <button onClick={onRetry} className="retry-button">
          Try Again
        </button>
      )}
    </div>
  );
}
```

---

## Best Practices

### ✅ Do
- Use Error Boundaries for component errors
- Provide user-friendly error messages
- Log errors for debugging
- Handle network errors gracefully
- Validate forms before submission
- Show loading states during async operations
- Offer retry mechanisms when appropriate

### ❌ Don't
- Don't expose technical error details to users
- Don't ignore errors silently
- Don't use try-catch for control flow
- Don't forget to handle loading/error states
- Don't let errors crash the entire app

---

## Related Guidelines

- **Architectural Principles:** See `architectural-principles.md` for component patterns
- **Testing:** See `testing-standards.md` for testing error scenarios
- **Documentation Standards:** See `../global/documentation-standards.md`

---

**Note:** This is a living document. Update as error handling patterns evolve.
