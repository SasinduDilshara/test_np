import ballerina/test;
import ballerina/time;

@test:Config {
    groups: ["guest"]
}
function testGuestRegistration() returns error? {
    Guest testGuest = createTestGuest();
    string|error result = registerGuest(testGuest);
    
    if result is string {
        test:assertNotEquals(result, "", "Guest ID should not be empty");
        
        // Verify guest details
        Guest|error storedGuest = getGuestDetails(result);
        if storedGuest is Guest {
            test:assertEquals(storedGuest.firstName, testGuest.firstName);
            test:assertEquals(storedGuest.lastName, testGuest.lastName);
            test:assertEquals(storedGuest.email, testGuest.email);
        } else {
            test:assertFail("Failed to retrieve guest details");
        }
    } else {
        test:assertFail("Guest registration failed");
    }
}

@test:Config {
    groups: ["guest", "validation"]
}
function testInvalidGuestRegistration() returns error? {
    Guest invalidGuest = {
        firstName: "",
        lastName: "",
        email: "invalid-email",
        phoneNumber: "123",
        company: "",
        idType: "",
        idNumber: ""
    };
    string|error result = registerGuest(invalidGuest);
    test:assertTrue(result is error);
}

@test:Config {
    groups: ["visit"]
}
function testVisitCreationAndTracking() returns error? {
    // Register guest first
    Guest testGuest = createTestGuest();
    string guestId = check registerGuest(testGuest);
    
    // Create visit
    string|error visitResult = createVisit(check int:fromString(guestId));
    if visitResult is string {
        test:assertNotEquals(visitResult, "", "Visit ID should not be empty");
        
        // Check-in guest
        check checkInGuest(
            check int:fromString(visitResult),
            time:utcToString(time:utcNow())
        );
        
        // Verify active visits
        Visit[]|error activeVisits = getActiveVisits();
        if activeVisits is Visit[] {
            test:assertTrue(activeVisits.length() > 0);
        }
        
        // Check-out guest
        check checkOutGuest(
            check int:fromString(visitResult),
            time:utcToString(time:utcNow())
        );
    }
}

@test:Config {
    groups: ["badge"]
}
function testBadgeGeneration() returns error? {
    Badge testBadge = createTestBadge();
    Badge|error result = generateBadge(testBadge);
    
    if result is Badge {
        test:assertNotEquals(result.badgeId, (), "Badge ID should be generated");
        test:assertEquals(result.accessLevel, testBadge.accessLevel);
        test:assertEquals(result.badgeType, testBadge.badgeType);
    } else {
        test:assertFail("Badge generation failed");
    }
}

@test:Config {
    groups: ["host"]
}
function testHostRetrieval() returns error? {
    Host|error result = getHostDetails("H001");
    if result is Host {
        test:assertEquals(result.department, "IT");
        test:assertTrue(result.email.length() > 0);
    } else {
        test:assertFail("Host retrieval failed");
    }
}

@test:Config {
    groups: ["security"]
}
function testVisitLogging() returns error? {
    VisitLog log = {
        visitId: 1,
        action: "CHECK_IN",
        timestamp: time:utcToString(time:utcNow()),
        details: "Test check-in"
    };
    check logVisitAction(log);
}

@test:Config {
    groups: ["integration"]
}
function testEndToEndVisitFlow() returns error? {
    // 1. Register Guest
    Guest testGuest = createTestGuest();
    string guestId = check registerGuest(testGuest);
    
    // 2. Create Visit
    string visitId = check createVisit(check int:fromString(guestId));
    
    // 3. Generate Badge
    Badge testBadge = {
        guestId: guestId,
        visitId: visitId,
        badgeType: "TEMPORARY",
        validFrom: time:utcToString(time:utcNow()),
        validTo: time:utcToString(time:utcNow()),
        accessLevel: "VISITOR"
    };
    Badge generatedBadge = check generateBadge(testBadge);
    
    // 4. Check-in
    check checkInGuest(check int:fromString(visitId), time:utcToString(time:utcNow()));
    
    // 5. Verify Active Visit
    Visit[] activeVisits = check getActiveVisits();
    test:assertTrue(activeVisits.length() > 0);
    
    // 6. Check-out
    check checkOutGuest(check int:fromString(visitId), time:utcToString(time:utcNow()));
}