from pydantic import BaseModel
from datetime import date
from typing import List, Optional

class CycleBase(BaseModel):
    start_date: date
    cycle_length: int
    menstruation_length: int
    intercourse_dates: List[date] = []

class CycleCreate(CycleBase):
    user_id: int

class CycleResponse(CycleBase):
    id: int
    user_id: int
    
    class Config:
        from_attributes = True

class CycleCalculations(BaseModel):
    cycle_data: CycleResponse
    ovulation_date: date
    fertile_window: List[date]
    menstruation_period: List[date]
    safe_days: List[date]
    current_phase: str
    days_until_next_period: int
    
class IntercourseToggle(BaseModel):
    date: date
    action: str  # "add" or "remove"

class UserCreate(BaseModel):
    username: str
    email: str

class UserResponse(BaseModel):
    id: int
    username: str
    email: str
    
    class Config:
        from_attributes = True