
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    country VARCHAR(50),
    join_date DATE
);


CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(20),
    open_date DATE,
    is_active BOOLEAN,
    balance DECIMAL(12,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


CREATE TABLE transactions (
    txn_id INT PRIMARY KEY,
    account_id INT,
    txn_date DATE,
    txn_type VARCHAR(20),
    amount DECIMAL(10,2),
    channel VARCHAR(20),
    note TEXT,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);
