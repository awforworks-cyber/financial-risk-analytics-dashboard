-- populate_dim_product.sql
-- Populates dim_product with SaaS products/plans

-- Clear existing data
TRUNCATE TABLE dbo.dim_product;

INSERT INTO dbo.dim_product (
    product_id,
    product_name,
    plan_type,
    module,
    base_monthly_price
)
VALUES
    (1, 'Core Basic',        'Basic',      'Core',      49.00),
    (2, 'Core Pro',          'Pro',        'Core',      99.00),
    (3, 'Core Enterprise',   'Enterprise', 'Core',     199.00),
    (4, 'Analytics Add-on',  'Pro',        'Analytics', 79.00),
    (5, 'Analytics Suite',   'Enterprise', 'Analytics',149.00),
    (6, 'Support Add-on',    'Basic',      'Add-on',    29.00),
    (7, 'Support Premium',   'Pro',        'Add-on',    59.00);
