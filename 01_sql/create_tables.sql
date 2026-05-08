DROP TABLE IF EXISTS contracts;
DROP TABLE IF EXISTS monthly_performance;

CREATE TABLE contracts (
    contract_id TEXT PRIMARY KEY,
    client_name TEXT NOT NULL,
    industry TEXT,
    monthly_rate NUMERIC(10,2),
    start_date DATE,
    renewal_date DATE,
    service_frequency TEXT,
    contract_status TEXT
);

CREATE TABLE monthly_performance (
    month TEXT,
    contract_id TEXT,
    payment_status TEXT,
    days_late INTEGER,
    inspection_score NUMERIC(5,2),
    complaints INTEGER,
    labor_hours NUMERIC(8,2),
    supply_cost NUMERIC(10,2),
    estimated_labor_cost NUMERIC(10,2),
    FOREIGN KEY (contract_id) REFERENCES contracts(contract_id)
);
