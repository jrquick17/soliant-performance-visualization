SELECT pebpc.payableChargeID,
       MIN(CASE
             WHEN peb.batchStatusLookupID IN (1, 2)
               THEN 2
             ELSE 99 -- Setting to 99 so it's ignored in the MIN above
         END) AS statusID
FROM Bullhorn1.BH_PayExportBatchPayableCharge pebpc WITH (NOLOCK)
       INNER JOIN bullhorn1.BH_PayExportBatch peb WITH (NOLOCK)
                  ON peb.payExportBatchID = pebpc.payExportBatchID
GROUP BY pebpc.payableChargeID;
