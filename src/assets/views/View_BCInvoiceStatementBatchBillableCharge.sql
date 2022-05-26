SELECT MIN(isb.batchStatusLookupID)
FROM Bullhorn1.BH_InvoiceStatementBatchBillableCharge isbbc WITH (NOLOCK)
       LEFT JOIN Bullhorn1.BH_InvoiceStatementBatch isb WITH (NOLOCK)
                 ON isb.invoiceStatementBatchID = isbbc.invoiceStatementBatchID
WHERE isbbc.billableChargeID = innerCharge.billableChargeID;
