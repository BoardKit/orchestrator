# Architectural Principles - {{REPO_NAME}}

**Repository:** {{REPO_NAME}}
**Tech Stack:** React + TypeScript
**Last Updated:** {{DATE}}

---

## Overview

This document defines architectural patterns and principles for the {{REPO_NAME}} React application. Follow these guidelines to maintain consistency and code quality.

---

## Project Structure

```
{{REPO_NAME}}/
├── src/
│   ├── components/       # Reusable React components
│   ├── pages/           # Page-level components (routes)
│   ├── hooks/           # Custom React hooks
│   ├── services/        # API clients and external services
│   ├── utils/           # Utility functions
│   ├── types/           # TypeScript type definitions
│   ├── contexts/        # React Context providers
│   └── App.tsx          # Root component
├── public/              # Static assets
└── tests/               # Test files
```

---

## Component Organization

### Component Types

**Presentational Components:**
- Pure UI components
- Receive data via props
- No business logic or API calls
- Located in `src/components/`

**Container Components:**
- Connect to state/context
- Handle business logic
- Fetch data and pass to presentational components
- Located in `src/pages/` or `src/components/containers/`

**Page Components:**
- Top-level route components
- Compose container and presentational components
- Located in `src/pages/`

### File Naming

- Components: `PascalCase.tsx` (e.g., `UserProfile.tsx`)
- Hooks: `camelCase.ts` starting with `use` (e.g., `useAuth.ts`)
- Utils: `camelCase.ts` (e.g., `formatDate.ts`)
- Types: `PascalCase.ts` or `camelCase.types.ts`

---

## State Management

### Local State
Use `useState` for component-local state:
```typescript
const [count, setCount] = useState<number>(0);
```

### Shared State
Use React Context for shared state across components:
```typescript
// src/contexts/AuthContext.tsx
export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  // ...
  return <AuthContext.Provider value={{ user, setUser }}>{children}</AuthContext.Provider>;
}
```

### Complex State
For complex state logic, use `useReducer`:
```typescript
const [state, dispatch] = useReducer(reducer, initialState);
```

---

## Component Patterns

### Functional Components (Preferred)
Always use functional components with hooks:
```typescript
interface UserCardProps {
  user: User;
  onEdit: (id: string) => void;
}

export function UserCard({ user, onEdit }: UserCardProps) {
  return (
    <div className="user-card">
      <h3>{user.name}</h3>
      <button onClick={() => onEdit(user.id)}>Edit</button>
    </div>
  );
}
```

### Custom Hooks
Extract reusable logic into custom hooks:
```typescript
// src/hooks/useApi.ts
export function useApi<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    fetchData();
  }, [url]);

  return { data, loading, error };
}
```

---

## Data Fetching

### API Service Layer
Centralize API calls in service files:
```typescript
// src/services/userService.ts
export const userService = {
  async getUser(id: string): Promise<User> {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) throw new Error('Failed to fetch user');
    return response.json();
  },

  async updateUser(id: string, data: Partial<User>): Promise<User> {
    const response = await fetch(`/api/users/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    if (!response.ok) throw new Error('Failed to update user');
    return response.json();
  },
};
```

### Using Services in Components
```typescript
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    userService.getUser(userId)
      .then(setUser)
      .catch(handleError)
      .finally(() => setLoading(false));
  }, [userId]);

  if (loading) return <LoadingSpinner />;
  if (!user) return <ErrorMessage />;
  return <UserCard user={user} />;
}
```

---

## TypeScript Usage

### Props Interfaces
Always define props interfaces:
```typescript
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}
```

### Type Safety
Avoid `any`, use proper types:
```typescript
// ❌ Bad
function processData(data: any) { ... }

// ✅ Good
function processData(data: User[]) { ... }
```

### Generic Components
Use generics for reusable components:
```typescript
interface ListProps<T> {
  items: T[];
  renderItem: (item: T) => ReactNode;
}

function List<T>({ items, renderItem }: ListProps<T>) {
  return <ul>{items.map(renderItem)}</ul>;
}
```

---

## Performance Optimization

### Memoization
Use `useMemo` for expensive calculations:
```typescript
const sortedUsers = useMemo(
  () => users.sort((a, b) => a.name.localeCompare(b.name)),
  [users]
);
```

### Callback Memoization
Use `useCallback` for callback functions passed to child components:
```typescript
const handleClick = useCallback(() => {
  // ...
}, [dependencies]);
```

### Component Memoization
Use `React.memo` for components that render often with same props:
```typescript
export const ExpensiveComponent = React.memo(function ExpensiveComponent({ data }: Props) {
  // ...
});
```

---

## Styling

### Approach
{{STYLING_APPROACH}} <!-- To be filled during setup: CSS Modules, Styled Components, Tailwind, etc. -->

### Class Naming (if using CSS)
Use BEM convention:
```css
.user-card { }
.user-card__header { }
.user-card__header--highlighted { }
```

---

## Cross-Cutting Concerns

### Error Boundaries
Use error boundaries for graceful error handling:
```typescript
class ErrorBoundary extends React.Component<Props, State> {
  static getDerivedStateFromError(error: Error) {
    return { hasError: true };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    logError(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback />;
    }
    return this.props.children;
  }
}
```

### Loading States
Always handle loading states explicitly:
```typescript
if (loading) return <LoadingSpinner />;
if (error) return <ErrorMessage error={error} />;
if (!data) return null;
return <Content data={data} />;
```

---

## Related Guidelines

- **Error Handling:** See `error-handling.md` for React error patterns
- **Testing:** See `testing-standards.md` for Jest and React Testing Library patterns
- **Documentation Standards:** See `../global/documentation-standards.md`

---

**Note:** This is a living document. Update as the architecture evolves.
