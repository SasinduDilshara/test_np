-- Transaction logs table for MySQL
CREATE TABLE transaction_logs (
    log_id VARCHAR(36) PRIMARY KEY,
    operation VARCHAR(20) NOT NULL,
    claim_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(100) NOT NULL,
    details TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_claim_id ON transaction_logs(claim_id);
CREATE INDEX idx_user_id ON transaction_logs(user_id);