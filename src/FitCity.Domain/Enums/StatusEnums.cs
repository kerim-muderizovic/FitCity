namespace FitCity.Domain.Enums;

public enum UserRole
{
    User = 1,
    Trainer = 2,
    GymAdministrator = 3,
    CentralAdministrator = 4
}

public enum MembershipRequestStatus
{
    Pending = 1,
    Approved = 2,
    Rejected = 3,
    Cancelled = 4
}

public enum MembershipStatus
{
    Active = 1,
    Expired = 2,
    Cancelled = 3,
    Suspended = 4
}

public enum TrainingSessionStatus
{
    Pending = 1,
    Confirmed = 2,
    Cancelled = 3,
    Completed = 4
}

public enum PaymentMethod
{
    Card = 1,
    Cash = 2,
    BankTransfer = 3,
    PayPal = 4
}

public enum PaymentStatus
{
    Unpaid = 1,
    Paid = 2
}
