// Test data generation utilities
function createTestGuest() returns Guest => {
    firstName: "John",
    lastName: "Doe",
    email: "john.doe@test.com",
    phoneNumber: "1234567890",
    company: "Test Corp",
    idType: "Passport",
    idNumber: "P123456",
    photoId: "photo123.jpg"
};

function createTestHost() returns Host => {
    hostId: "H001",
    firstName: "Jane",
    lastName: "Smith",
    email: "jane.smith@company.com",
    department: "IT",
    phoneNumber: "9876543210"
};

function createTestBadge() returns Badge => {
    guestId: "G001",
    visitId: "V001",
    badgeType: "TEMPORARY",
    validFrom: "2024-01-01T09:00:00",
    validTo: "2024-01-01T17:00:00",
    accessLevel: "VISITOR"
};

function createTestVisit() returns Visit => {
    guestId: "G001",
    hostId: "H001",
    purpose: "Business Meeting",
    status: "SCHEDULED"
};