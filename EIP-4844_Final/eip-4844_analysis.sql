SELECT
  "Date",
  SUM("Gas Spent (USD)") AS "Gas Spent (USD)",
  name
FROM (
  SELECT
    DATE_TRUNC('week', block_time) AS "Date",
    SUM(gas_spent_usd) AS "Gas Spent (USD)",
    name
  FROM rollup_economics_ethereum.l1_data_fees
  WHERE
    block_time >= CURRENT_DATE - INTERVAL '365' day
    AND name IN (
      SELECT name
      FROM rollup_economics_ethereum.l1_data_fees
      GROUP BY name
      ORDER BY SUM(gas_spent_usd) DESC
      LIMIT 20
    )
  GROUP BY
    1, 3

  UNION ALL

  SELECT
    DATE_TRUNC('week', block_time) AS "Date",
    SUM(gas_spent_usd) AS "Gas Spent (USD)",
    name
  FROM rollup_economics_ethereum.l1_verification_fees
  WHERE
    block_time >= CURRENT_DATE - INTERVAL '365' day
    AND name IN (
      SELECT name
      FROM rollup_economics_ethereum.l1_verification_fees
      GROUP BY name
      ORDER BY SUM(gas_spent_usd) DESC
      LIMIT 20
    )
  GROUP BY
    1, 3
) subquery
GROUP BY
  "Date", name
