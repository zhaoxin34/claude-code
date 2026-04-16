# E-commerce Full-Stack Project Implementation Plan

## Context

The workspace at `/Volumes/data/working/ai/matrix/website/` currently contains only prompt files (`prompts/ecommerce-*.md`) that define the architecture for an e-commerce application. The user wants to generate the complete full-stack implementation based on these prompts.

## Project Structure

```
ecommerce/                          # Project root (at website/ecommerce/)
├── .gitignore
├── Makefile
├── README.md
├── .env.example
├── docker/
│   ├── docker-compose.yml
│   ├── frontend.Dockerfile
│   └── backend.Dockerfile
├── hooks/
│   ├── pre-commit
│   └── commit-msg
├── backend/                          # Python FastAPI backend
│   ├── src/app/
│   │   ├── __init__.py
│   │   ├── main.py                  # FastAPI entry point
│   │   ├── config.py                # Pydantic Settings
│   │   ├── database.py              # SQLAlchemy setup
│   │   ├── dependencies.py          # get_db, get_current_user
│   │   ├── models/                  # SQLAlchemy models
│   │   ├── schemas/                 # Pydantic schemas
│   │   ├── api/v1/                  # API routes
│   │   ├── services/                # Business logic
│   │   ├── repositories/            # Data access
│   │   ├── core/                    # Security, exceptions
│   │   └── utils/                   # Helpers
│   ├── tests/
│   ├── alembic/
│   ├── scripts/
│   ├── requirements.txt
│   └── alembic.ini
└── frontend/                        # React TypeScript frontend
    ├── src/
    │   ├── api/                     # Axios + API modules
    │   ├── components/
    │   ├── pages/
    │   ├── hooks/
    │   ├── stores/                  # Zustand stores
    │   ├── types/
    │   ├── utils/
    │   └── styles/
    ├── public/
    ├── package.json
    ├── vite.config.ts
    └── tsconfig.json
```

## Implementation Order

### Phase 1: Project Foundation
1. Create directory structure
2. Create `.gitignore`
3. Setup Git hooks (pre-commit, commit-msg)
4. Create `Makefile`
5. Create `.env.example`
6. Create Docker configuration

### Phase 2: Backend Core Infrastructure
- `backend/src/app/config.py` - Settings from env
- `backend/src/app/database.py` - SQLAlchemy engine/session
- `backend/src/app/dependencies.py` - get_db, get_current_user
- `backend/src/app/core/security.py` - JWT, password hashing
- `backend/src/app/core/exceptions.py` - Custom exceptions
- `backend/src/app/main.py` - FastAPI app entry point

### Phase 3: Backend Models & Migrations
- Models: user, category, product, address, order, cart
- Alembic initial migration

### Phase 4: Backend Schemas
- Pydantic schemas for all models (Create, Update, Schema)

### Phase 5: Backend Repositories & Services
- Repository layer for each model
- Service layer with business logic

### Phase 6: Backend API Routes
- API v1: auth, users, products, categories, cart, orders, addresses
- Health check endpoints

### Phase 7: Frontend Setup
- Vite + React + TypeScript project
- ESLint + Prettier + TypeScript config
- Dependencies: antd, axios, react-router-dom, zustand, react-hook-form, zod

### Phase 8: Frontend Core
- Axios instance with interceptors
- Zustand stores (auth, cart, ui)
- TypeScript types

### Phase 9: Frontend Components & Pages
- Layout: Header, Footer, MainLayout
- Product: ProductCard, ProductList, ProductDetail
- Cart: CartItem, CartSummary
- Order: OrderForm, OrderList
- Pages: Home, ProductList, ProductDetail, Cart, Checkout, Login, Register, UserProfile, OrderList

### Phase 10: Scripts & Tests
- Database seed script
- Pytest configuration and tests
- Frontend tests

## Critical Files to Reuse

Based on the prompts, these patterns should be reused:
- `backend/src/app/models/user.py` - Base User model (reference for other models)
- `backend/src/app/schemas/product.py` - Schema pattern for all schemas
- `backend/src/app/services/product_service.py` - Service pattern
- `backend/src/app/repositories/product_repo.py` - Repository pattern
- `frontend/src/api/axios.ts` - Single axios instance
- `frontend/src/stores/cartStore.ts` - Zustand store pattern

## Dependencies

**Backend:** fastapi, uvicorn, sqlalchemy, pymysql, pydantic, pydantic-settings, python-jose, passlib, bcrypt, alembic, redis, python-multipart, pytest, black, isort, flake8, mypy

**Frontend:** react, react-dom, react-router-dom, antd, @ant-design/icons, axios, zustand, react-hook-form, @hookform/resolvers, zod, recharts, typescript, vite, @vitejs/plugin-react, eslint, prettier

## Verification

```bash
# Backend tests
make test  # cd backend && pytest -v

# Frontend type-check and lint
make lint  # flake8 + mypy (backend), npm run lint (frontend)
make type-check  # mypy + tsc --noEmit

# Docker full stack
make docker-up  # Starts MySQL, Redis, backend, frontend

# Smoke test
curl http://localhost:8000/api/v1/health
curl http://localhost:8000/docs  # Swagger UI
curl http://localhost:3000  # Frontend
```
