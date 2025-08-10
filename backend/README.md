# Elles Backend API

FastAPI backend for the Elles menstrual cycle tracking application.

## Features

- **Cycle Management**: Create and manage menstrual cycles
- **Cycle Calculations**: Automatic calculation of ovulation, fertile window, and safe days
- **Intercourse Tracking**: Track intimate relationships with heart icons
- **RESTful API**: Clean and documented API endpoints
- **MySQL Database**: Robust data storage with SQLAlchemy ORM

## Setup

1. **Install Dependencies**
```bash
pip install -r requirements.txt
```

2. **Database Setup**
Make sure you have MySQL running and create a database called `elles_db`:
```sql
CREATE DATABASE elles_db;
```

3. **Environment Variables**
Update the `DATABASE_URL` in `database.py` with your MySQL credentials:
```python
DATABASE_URL = "mysql+mysqlconnector://username:password@localhost:3306/elles_db"
```

4. **Run the Server**
```bash
python run.py
```

The API will be available at `http://localhost:8000`

## API Endpoints

### Cycles
- `POST /cycles/` - Create a new cycle
- `GET /cycles/{user_id}` - Get cycle calculations for a user
- `GET /cycles/{user_id}/all` - Get all cycles for a user
- `PUT /cycles/{cycle_id}` - Update a cycle
- `DELETE /cycles/{cycle_id}` - Delete a cycle

### Intercourse Tracking
- `POST /cycles/{user_id}/intercourse` - Toggle intercourse for a specific date

### Users
- `POST /users/` - Create a new user
- `GET /users/{user_id}` - Get user information

## Cycle Calculations

The backend automatically calculates:
- **Ovulation Date**: `start_date + (cycle_length - 14)`
- **Fertile Window**: `[ovulation - 4 days to ovulation + 1 day]`
- **Menstruation Period**: `start_date to start_date + menstruation_length`
- **Safe Days**: Days that are not in menstruation or fertile periods

## Development

- View API documentation at `http://localhost:8000/docs`
- Interactive API testing at `http://localhost:8000/redoc`
- Database tables are automatically created on first run