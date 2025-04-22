select *
from {{ ref('fct_orders') }}
where 
   order_date > current_date
   or order_date < date('1990-01-01')
