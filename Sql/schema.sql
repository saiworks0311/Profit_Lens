
-- 1. Product Categories Table
CREATE TABLE dim_product_categories (
    category_key INT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL
);

-- 2. Product Subcategories Table
CREATE TABLE dim_product_subcategories (
    subcategory_key INT PRIMARY KEY,
    subcategory_name VARCHAR(50) NOT NULL,
    category_key INT REFERENCES dim_product_categories(category_key)
);

-- 3. Products Table
CREATE TABLE dim_products (
    product_key INT PRIMARY KEY,
    product_subcategory_key INT,
    product_sku VARCHAR(50),
    product_name VARCHAR(100),
    model_name VARCHAR(100),
    product_description TEXT,
    product_color VARCHAR(30),
    product_size VARCHAR(10),       -- Notice: VARCHAR because you found mixed types ("M" and "52")!
    product_style VARCHAR(10),
    product_cost NUMERIC(10, 2),
    product_price NUMERIC(10, 2)
);

-- 4. Territories Table
CREATE TABLE dim_territories (
    sales_territory_key INT PRIMARY KEY,
    region VARCHAR(50),
    country VARCHAR(50),
    continent VARCHAR(50)
);

-- 5. Customers Table
CREATE TABLE dim_customers (
    customer_key INT PRIMARY KEY,
    prefix VARCHAR(10),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    birth_date DATE,
    marital_status VARCHAR(5),
    gender VARCHAR(5),
    email_address VARCHAR(100),
    annual_income NUMERIC(12, 2),
    total_children INT,
    education_level VARCHAR(50),
    occupation VARCHAR(50),
    home_owner VARCHAR(5)
);

-- 6. Returns Fact Table
CREATE TABLE fact_returns (
    return_date DATE,
    territory_key INT,
    product_key INT,
    return_quantity INT
);

-- 7. Unified Sales Fact Table (All years combined)
CREATE TABLE fact_sales (
    order_date DATE,
    stock_date DATE,
    order_number VARCHAR(50),
    product_key INT,
    customer_key INT,
    territory_key INT,
    order_line_item INT,
    order_quantity INT
);

ALTER DATABASE profitlens_db
SET datestyle TO 'MDY';

ALTER TABLE dim_customers 
ALTER COLUMN annual_income TYPE VARCHAR(50);