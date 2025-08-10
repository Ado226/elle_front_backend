from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from datetime import date
from typing import List

from database import get_db, create_tables, Cycle, User
from schemas import CycleCreate, CycleResponse, CycleCalculations, IntercourseToggle, UserCreate, UserResponse
from cycle_calculator import CycleCalculator

app = FastAPI(title="Elles API", description="API for African-inspired health and intimacy assistant")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create database tables on startup
@app.on_event("startup")
def startup_event():
    create_tables()

# User endpoints
@app.post("/users/", response_model=UserResponse)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    db_user = User(username=user.username, email=user.email)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@app.get("/users/{user_id}", response_model=UserResponse)
def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    return user

# Cycle endpoints
@app.post("/cycles/", response_model=CycleResponse)
def create_cycle(cycle: CycleCreate, db: Session = Depends(get_db)):
    """Enregistrer un nouveau cycle"""
    
    # Check if user exists
    user = db.query(User).filter(User.id == cycle.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    
    # Create new cycle
    db_cycle = Cycle(
        user_id=cycle.user_id,
        start_date=cycle.start_date,
        cycle_length=cycle.cycle_length,
        menstruation_length=cycle.menstruation_length,
        intercourse_dates=cycle.intercourse_dates
    )
    
    db.add(db_cycle)
    db.commit()
    db.refresh(db_cycle)
    
    return db_cycle

@app.get("/cycles/{user_id}", response_model=CycleCalculations)
def get_cycle_data(user_id: int, db: Session = Depends(get_db)):
    """Renvoyer toutes les données calculées : règles, ovulation, fertilité, jours sûrs"""
    
    # Get the most recent cycle for the user
    cycle = db.query(Cycle).filter(Cycle.user_id == user_id).order_by(Cycle.id.desc()).first()
    
    if not cycle:
        raise HTTPException(status_code=404, detail="Aucun cycle trouvé pour cet utilisateur")
    
    # Convert to response model
    cycle_response = CycleResponse(
        id=cycle.id,
        user_id=cycle.user_id,
        start_date=cycle.start_date,
        cycle_length=cycle.cycle_length,
        menstruation_length=cycle.menstruation_length,
        intercourse_dates=cycle.intercourse_dates or []
    )
    
    # Calculate all cycle data
    calculations = CycleCalculator.get_full_calculations(cycle_response)
    
    return calculations

@app.post("/cycles/{user_id}/intercourse")
def toggle_intercourse(user_id: int, intercourse_data: IntercourseToggle, db: Session = Depends(get_db)):
    """Ajouter ou retirer un ❤️ pour un jour donné"""
    
    # Get the most recent cycle for the user
    cycle = db.query(Cycle).filter(Cycle.user_id == user_id).order_by(Cycle.id.desc()).first()
    
    if not cycle:
        raise HTTPException(status_code=404, detail="Aucun cycle trouvé pour cet utilisateur")
    
    # Get current intercourse dates
    intercourse_dates = cycle.intercourse_dates or []
    
    # Convert date to string for JSON storage
    date_str = intercourse_data.date.isoformat()
    
    if intercourse_data.action == "add":
        if date_str not in intercourse_dates:
            intercourse_dates.append(date_str)
    elif intercourse_data.action == "remove":
        if date_str in intercourse_dates:
            intercourse_dates.remove(date_str)
    
    # Update the cycle
    cycle.intercourse_dates = intercourse_dates
    db.commit()
    
    return {"message": "Statut de rapport mis à jour", "intercourse_dates": intercourse_dates}

@app.get("/cycles/{user_id}/all", response_model=List[CycleResponse])
def get_all_cycles(user_id: int, db: Session = Depends(get_db)):
    """Get all cycles for a user"""
    cycles = db.query(Cycle).filter(Cycle.user_id == user_id).order_by(Cycle.start_date.desc()).all()
    return cycles

@app.put("/cycles/{cycle_id}", response_model=CycleResponse)
def update_cycle(cycle_id: int, cycle_update: CycleCreate, db: Session = Depends(get_db)):
    """Update an existing cycle"""
    cycle = db.query(Cycle).filter(Cycle.id == cycle_id).first()
    
    if not cycle:
        raise HTTPException(status_code=404, detail="Cycle non trouvé")
    
    # Update cycle data
    cycle.start_date = cycle_update.start_date
    cycle.cycle_length = cycle_update.cycle_length
    cycle.menstruation_length = cycle_update.menstruation_length
    cycle.intercourse_dates = cycle_update.intercourse_dates
    
    db.commit()
    db.refresh(cycle)
    
    return cycle

@app.delete("/cycles/{cycle_id}")
def delete_cycle(cycle_id: int, db: Session = Depends(get_db)):
    """Delete a cycle"""
    cycle = db.query(Cycle).filter(Cycle.id == cycle_id).first()
    
    if not cycle:
        raise HTTPException(status_code=404, detail="Cycle non trouvé")
    
    db.delete(cycle)
    db.commit()
    
    return {"message": "Cycle supprimé"}

@app.get("/")
def root():
    return {"message": "Bienvenue sur l'API Elles - Assistant santé et intimité pour femmes"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)