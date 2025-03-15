import ballerina/http;
import ballerina/uuid;
import ballerinax/postgresql;
import ballerinax/mysql;
import ballerina/sql;

// Database client
final postgresql:Client dbClient = check new (
    username = dbUser,
    password = dbPassword,
    database = dbName,
    host = dbHost,
    port = 5432
);

// MySQL Log Database client
final mysql:Client logDbClient = check new (
    host = logDbHost,
    user = logDbUser,
    password = logDbPassword,
    database = logDbName,
    port = 3306
);

service /claims on new http:Listener(8080) {
    // Submit a new claim
    resource function post submit(@http:Header string userId, ClaimRequest claim) returns ClaimResponse|error {
        string claimId = uuid:createType1AsString();
        decimal totalAmount = check getTotalClaimsAmount(userId);
        totalAmount += claim.amount;

        string status;
        string message;

        if (totalAmount <= 10.0d) {
            status = "APPROVED";
            message = "Claim automatically approved";
        } else {
            status = "PENDING";
            message = "Claim pending approval as total claims exceed $10";
        }

        Claim newClaim = {
            claimId: claimId,
            userId: userId,
            amount: claim.amount,
            status: status,
            description: claim.description
        };

        _ = check dbClient->execute(`
            INSERT INTO claims (claim_id, user_id, amount, status, description)
            VALUES (${newClaim.claimId}, ${newClaim.userId}, ${newClaim.amount}, ${newClaim.status}, ${newClaim.description})
        `);

        // Log the transaction
        _ = check logTransaction("CREATE", claimId, userId, string `New claim created with amount: ${claim.amount}, status: ${status}`);

        return {
            claimId: claimId,
            status: status,
            message: message
        };
    }

    // Get claim status
    resource function get status/[string claimId](@http:Header string userId) returns StatusResponse|error {
        record {|string status;|} result = check dbClient->queryRow(`
            SELECT status FROM claims 
            WHERE claim_id = ${claimId} AND user_id = ${userId}
        `);

        // Log the transaction
        _ = check logTransaction("READ", claimId, userId, string `Status checked: ${result.status}`);

        return {
            status: result.status,
            message: string `Claim status: ${result.status}`
        };
    }

    // Delete a claim
    resource function delete [string claimId](@http:Header string userId) returns DeleteResponse|error {
        sql:ExecutionResult result = check dbClient->execute(`
            DELETE FROM claims 
            WHERE claim_id = ${claimId} AND user_id = ${userId}
        `);
        
        if result.affectedRowCount == 0 {
            // Log failed deletion attempt
            _ = check logTransaction("DELETE_FAILED", claimId, userId, "Claim not found or unauthorized to delete");
            return {
                success: false,
                message: "Claim not found or unauthorized to delete"
            };
        }
        
        // Log successful deletion
        _ = check logTransaction("DELETE", claimId, userId, "Claim deleted successfully");
        return {
            success: true,
            message: "Claim deleted successfully"
        };
    }
}

// Helper function to get total claims amount for a user
function getTotalClaimsAmount(string userId) returns decimal|error {
    record {|decimal total;|} result = check dbClient->queryRow(`
        SELECT COALESCE(SUM(amount), 0) as total 
        FROM claims 
        WHERE user_id = ${userId}
    `);
    return result.total;
}

// Helper function to log transactions
function logTransaction(string operation, string claimId, string userId, string details) returns error? {
    TransactionLog log = {
        logId: uuid:createType1AsString(),
        operation: operation,
        claimId: claimId,
        userId: userId,
        details: details
    };

    _ = check logDbClient->execute(`
        INSERT INTO transaction_logs (log_id, operation, claim_id, user_id, details)
        VALUES (${log.logId}, ${log.operation}, ${log.claimId}, ${log.userId}, ${log.details})
    `);
}