from datetime import date, timedelta
from typing import List, Tuple
from schemas import CycleResponse, CycleCalculations

class CycleCalculator:
    @staticmethod
    def calculate_ovulation_date(start_date: date, cycle_length: int) -> date:
        """Calculate ovulation date: start_date + (cycle_length - 14)"""
        return start_date + timedelta(days=cycle_length - 14)
    
    @staticmethod
    def calculate_fertile_window(ovulation_date: date) -> List[date]:
        """Calculate fertile window: [ovulation - 4 days to ovulation + 1 day]"""
        fertile_start = ovulation_date - timedelta(days=4)
        fertile_end = ovulation_date + timedelta(days=1)
        
        fertile_window = []
        current_date = fertile_start
        while current_date <= fertile_end:
            fertile_window.append(current_date)
            current_date += timedelta(days=1)
        
        return fertile_window
    
    @staticmethod
    def calculate_menstruation_period(start_date: date, menstruation_length: int) -> List[date]:
        """Calculate menstruation period: start to start + menstruation_length"""
        menstruation_period = []
        for i in range(menstruation_length):
            menstruation_period.append(start_date + timedelta(days=i))
        return menstruation_period
    
    @staticmethod
    def calculate_safe_days(cycle_data: CycleResponse) -> List[date]:
        """Calculate safe days (days that are not fertile or menstruation)"""
        start_date = cycle_data.start_date
        cycle_length = cycle_data.cycle_length
        
        # Calculate cycle end date
        cycle_end = start_date + timedelta(days=cycle_length - 1)
        
        # Get menstruation and fertile dates
        menstruation_dates = CycleCalculator.calculate_menstruation_period(
            start_date, cycle_data.menstruation_length
        )
        ovulation_date = CycleCalculator.calculate_ovulation_date(start_date, cycle_length)
        fertile_dates = CycleCalculator.calculate_fertile_window(ovulation_date)
        
        # Combine all non-safe dates
        non_safe_dates = set(menstruation_dates + fertile_dates)
        
        # Calculate safe days
        safe_days = []
        current_date = start_date
        while current_date <= cycle_end:
            if current_date not in non_safe_dates:
                safe_days.append(current_date)
            current_date += timedelta(days=1)
        
        return safe_days
    
    @staticmethod
    def get_current_phase(cycle_data: CycleResponse, current_date: date = None) -> str:
        """Determine current phase of the cycle"""
        if current_date is None:
            current_date = date.today()
        
        start_date = cycle_data.start_date
        ovulation_date = CycleCalculator.calculate_ovulation_date(start_date, cycle_data.cycle_length)
        menstruation_dates = CycleCalculator.calculate_menstruation_period(
            start_date, cycle_data.menstruation_length
        )
        fertile_dates = CycleCalculator.calculate_fertile_window(ovulation_date)
        
        if current_date in menstruation_dates:
            return "menstruation"
        elif current_date in fertile_dates:
            if current_date == ovulation_date:
                return "ovulation"
            else:
                return "fertile"
        else:
            return "safe"
    
    @staticmethod
    def days_until_next_period(cycle_data: CycleResponse, current_date: date = None) -> int:
        """Calculate days until next menstruation"""
        if current_date is None:
            current_date = date.today()
        
        start_date = cycle_data.start_date
        cycle_length = cycle_data.cycle_length
        
        # Calculate next period start
        next_period_start = start_date + timedelta(days=cycle_length)
        
        # If current date is past the next period start, calculate the following period
        while next_period_start <= current_date:
            next_period_start += timedelta(days=cycle_length)
        
        days_until = (next_period_start - current_date).days
        return days_until
    
    @staticmethod
    def get_full_calculations(cycle_data: CycleResponse) -> CycleCalculations:
        """Get all cycle calculations"""
        ovulation_date = CycleCalculator.calculate_ovulation_date(
            cycle_data.start_date, cycle_data.cycle_length
        )
        fertile_window = CycleCalculator.calculate_fertile_window(ovulation_date)
        menstruation_period = CycleCalculator.calculate_menstruation_period(
            cycle_data.start_date, cycle_data.menstruation_length
        )
        safe_days = CycleCalculator.calculate_safe_days(cycle_data)
        current_phase = CycleCalculator.get_current_phase(cycle_data)
        days_until_next = CycleCalculator.days_until_next_period(cycle_data)
        
        return CycleCalculations(
            cycle_data=cycle_data,
            ovulation_date=ovulation_date,
            fertile_window=fertile_window,
            menstruation_period=menstruation_period,
            safe_days=safe_days,
            current_phase=current_phase,
            days_until_next_period=days_until_next
        )