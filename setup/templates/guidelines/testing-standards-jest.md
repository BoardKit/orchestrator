# Testing Standards - {{REPO_NAME}}

**Repository:** {{REPO_NAME}}
**Tech Stack:** React + TypeScript + Jest + React Testing Library
**Last Updated:** {{DATE}}

---

## Overview

This document defines testing standards for the {{REPO_NAME}} React application. Consistent testing practices ensure code quality and prevent regressions.

---

## Testing Tools

- **Jest:** Test runner and assertion library
- **React Testing Library:** Component testing utilities
- **Testing Library User Event:** User interaction simulation
- **MSW (Mock Service Worker):** API mocking

---

## Test Structure

### File Organization
```
src/
├── components/
│   ├── UserCard.tsx
│   └── UserCard.test.tsx
├── hooks/
│   ├── useAuth.ts
│   └── useAuth.test.ts
└── utils/
    ├── formatDate.ts
    └── formatDate.test.ts
```

### Test File Naming
- Component tests: `ComponentName.test.tsx`
- Hook tests: `hookName.test.ts`
- Utility tests: `utilName.test.ts`

---

## Component Testing

### Basic Component Test
```typescript
// UserCard.test.tsx
import { render, screen } from '@testing-library/react';
import { UserCard } from './UserCard';

describe('UserCard', () => {
  const mockUser = {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
  };

  it('renders user information', () => {
    render(<UserCard user={mockUser} />);

    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
  });

  it('calls onEdit when edit button is clicked', async () => {
    const mockOnEdit = jest.fn();
    const { user } = render(<UserCard user={mockUser} onEdit={mockOnEdit} />);

    await user.click(screen.getByRole('button', { name: /edit/i }));

    expect(mockOnEdit).toHaveBeenCalledWith('1');
  });
});
```

### Testing with User Interactions
```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

describe('LoginForm', () => {
  it('submits form with entered credentials', async () => {
    const mockOnSubmit = jest.fn();
    const user = userEvent.setup();

    render(<LoginForm onSubmit={mockOnSubmit} />);

    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /submit/i }));

    expect(mockOnSubmit).toHaveBeenCalledWith({
      email: 'test@example.com',
      password: 'password123',
    });
  });

  it('displays validation errors', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={jest.fn()} />);

    // Submit empty form
    await user.click(screen.getByRole('button', { name: /submit/i }));

    expect(screen.getByText(/email is required/i)).toBeInTheDocument();
    expect(screen.getByText(/password is required/i)).toBeInTheDocument();
  });
});
```

---

## Testing Async Components

### With API Calls
```typescript
import { render, screen, waitFor } from '@testing-library/react';
import { rest } from 'msw';
import { setupServer } from 'msw/node';
import { UserProfile } from './UserProfile';

const server = setupServer(
  rest.get('/api/users/:id', (req, res, ctx) => {
    return res(
      ctx.json({
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
      })
    );
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('UserProfile', () => {
  it('loads and displays user data', async () => {
    render(<UserProfile userId="1" />);

    // Initially shows loading
    expect(screen.getByText(/loading/i)).toBeInTheDocument();

    // Wait for data to load
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });
  });

  it('handles error when API fails', async () => {
    server.use(
      rest.get('/api/users/:id', (req, res, ctx) => {
        return res(ctx.status(500));
      })
    );

    render(<UserProfile userId="1" />);

    await waitFor(() => {
      expect(screen.getByText(/error/i)).toBeInTheDocument();
    });
  });
});
```

---

## Hook Testing

### Testing Custom Hooks
```typescript
// useCounter.test.ts
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  it('initializes with default value', () => {
    const { result } = renderHook(() => useCounter());
    expect(result.current.count).toBe(0);
  });

  it('initializes with provided value', () => {
    const { result } = renderHook(() => useCounter(10));
    expect(result.current.count).toBe(10);
  });

  it('increments counter', () => {
    const { result } = renderHook(() => useCounter());

    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });

  it('decrements counter', () => {
    const { result } = renderHook(() => useCounter(5));

    act(() => {
      result.current.decrement();
    });

    expect(result.current.count).toBe(4);
  });
});
```

### Testing Hooks with Dependencies
```typescript
import { renderHook, waitFor } from '@testing-library/react';
import { useApi } from './useApi';

describe('useApi', () => {
  it('fetches data successfully', async () => {
    server.use(
      rest.get('/api/data', (req, res, ctx) => {
        return res(ctx.json({ value: 'test' }));
      })
    );

    const { result } = renderHook(() => useApi('/api/data'));

    expect(result.current.loading).toBe(true);

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.data).toEqual({ value: 'test' });
    expect(result.current.error).toBeNull();
  });
});
```

---

## Context Testing

### Testing with Context
```typescript
import { render, screen } from '@testing-library/react';
import { AuthProvider, useAuth } from './AuthContext';

function TestComponent() {
  const { user, login } = useAuth();
  return (
    <div>
      {user ? <span>Logged in as {user.name}</span> : <span>Not logged in</span>}
      <button onClick={() => login({ id: '1', name: 'Test User' })}>
        Login
      </button>
    </div>
  );
}

describe('AuthContext', () => {
  it('provides authentication state', async () => {
    const user = userEvent.setup();

    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    );

    expect(screen.getByText(/not logged in/i)).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: /login/i }));

    expect(screen.getByText(/logged in as test user/i)).toBeInTheDocument();
  });
});
```

---

## Snapshot Testing

### When to Use Snapshots
- Stable UI components
- Component props rendering
- Error messages and states

### Snapshot Test Example
```typescript
import { render } from '@testing-library/react';
import { ErrorMessage } from './ErrorMessage';

describe('ErrorMessage', () => {
  it('matches snapshot for error display', () => {
    const { container } = render(
      <ErrorMessage message="Something went wrong" />
    );
    expect(container.firstChild).toMatchSnapshot();
  });
});
```

---

## Mocking

### Mocking Modules
```typescript
// Mock entire module
jest.mock('./userService', () => ({
  getUser: jest.fn(),
  updateUser: jest.fn(),
}));

import { getUser } from './userService';

describe('UserProfile', () => {
  it('fetches user data', async () => {
    (getUser as jest.Mock).mockResolvedValue({
      id: '1',
      name: 'John Doe',
    });

    render(<UserProfile userId="1" />);

    await waitFor(() => {
      expect(getUser).toHaveBeenCalledWith('1');
    });
  });
});
```

### Mocking Specific Functions
```typescript
const mockFetch = jest.fn();
global.fetch = mockFetch as any;

mockFetch.mockResolvedValue({
  ok: true,
  json: async () => ({ data: 'test' }),
});
```

---

## Test Coverage

### Coverage Goals
- Statements: > 80%
- Branches: > 75%
- Functions: > 80%
- Lines: > 80%

### Running Coverage
```bash
npm test -- --coverage
```

### Coverage Configuration
```javascript
// jest.config.js
module.exports = {
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.test.{ts,tsx}',
    '!src/**/*.d.ts',
  ],
  coverageThresholds: {
    global: {
      statements: 80,
      branches: 75,
      functions: 80,
      lines: 80,
    },
  },
};
```

---

## Testing Best Practices

### ✅ Do
- Test user behavior, not implementation
- Use semantic queries (getByRole, getByLabelText)
- Test error states and edge cases
- Keep tests simple and focused
- Use meaningful test descriptions
- Mock external dependencies
- Clean up after tests

### ❌ Don't
- Don't test implementation details
- Don't use getByTestId as first choice
- Don't test third-party libraries
- Don't make tests dependent on each other
- Don't skip error cases
- Don't use shallow rendering

---

## Test Organization

### AAA Pattern
```typescript
describe('Component', () => {
  it('does something', () => {
    // Arrange - Set up test data
    const mockData = { /* ... */ };

    // Act - Perform action
    render(<Component data={mockData} />);

    // Assert - Verify results
    expect(screen.getByText('Expected')).toBeInTheDocument();
  });
});
```

### Descriptive Test Names
```typescript
// ❌ Bad
it('works', () => { /* ... */ });

// ✅ Good
it('displays user name when user data is loaded', () => { /* ... */ });
```

---

## Common Testing Patterns

### Testing Loading States
```typescript
it('shows loading indicator while fetching data', () => {
  render(<DataComponent />);
  expect(screen.getByRole('progressbar')).toBeInTheDocument();
});
```

### Testing Error States
```typescript
it('displays error message when fetch fails', async () => {
  server.use(
    rest.get('/api/data', (req, res, ctx) => res(ctx.status(500)))
  );

  render(<DataComponent />);

  await waitFor(() => {
    expect(screen.getByText(/error/i)).toBeInTheDocument();
  });
});
```

### Testing Conditional Rendering
```typescript
it('shows edit button only for admin users', () => {
  const adminUser = { id: '1', role: 'admin' };
  render(<UserProfile user={adminUser} />);

  expect(screen.getByRole('button', { name: /edit/i })).toBeInTheDocument();
});

it('hides edit button for regular users', () => {
  const regularUser = { id: '2', role: 'user' };
  render(<UserProfile user={regularUser} />);

  expect(screen.queryByRole('button', { name: /edit/i })).not.toBeInTheDocument();
});
```

---

## Related Guidelines

- **Architectural Principles:** See `architectural-principles.md` for component patterns
- **Error Handling:** See `error-handling.md` for error patterns to test
- **Documentation Standards:** See `../global/documentation-standards.md`

---

**Note:** This is a living document. Update as testing practices evolve.
