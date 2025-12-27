from pydantic import BaseModel


class Customer(BaseModel):
    name: str
    description: str | None
    email: str
    age: int


class Transaction(BaseModel):
    id: int
    amount: int
    description: str


class Invoice(BaseModel):
    id: int
    customer: Customer
    transactions: list[Transaction]
