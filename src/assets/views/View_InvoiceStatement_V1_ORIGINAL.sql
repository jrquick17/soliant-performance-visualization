SELECT invoiceStatement.invoiceStatementID
     , invoiceStatement.previousBalance
     , invoiceStatement.dateAdded
     , invoiceStatement.dateLastModified
     , invoiceStatement.billingPeriodEndDate
     , invoiceStatement.clientCorporationID
     , invoiceStatement.purchaseOrderNumber
     , invoiceStatement.paymentTerms
     , invoiceStatement.dueDate
     , invoiceStatement.currencyUnitID
     , invoiceStatement.billingProfileID
     , invoiceStatement.remitInstructions
     , invoiceStatement.invoiceStatementDate
     , invoiceStatement.taxAmount
     , invoiceStatement.discountAmount
     , invoiceStatement.surchargeAmount
     , invoiceStatement.userID
     , invoiceStatement.billingClientContactUserID
     , invoiceStatement.billingAttention
     , invoiceStatement.billingAddress1
     , invoiceStatement.billingAddress2
     , invoiceStatement.billingCity
     , invoiceStatement.billingState
     , invoiceStatement.billingZip
     , invoiceStatement.billingCountryID
     , invoiceStatement.invoiceStatementNumber
     , invoiceStatement.invoiceStatementTypeLookupID
     , invoiceStatement.invoiceStatementOrigin
     , invoiceStatement.invoiceTermID
     , invoiceStatement.billingScheduleID
     , invoiceStatement.billingCorporateUserID
     , invoiceStatement.deliveryMethod
     , invoiceStatement.deliveryMethodLookupID
     , invoiceStatement.isFinalized
     , invoiceStatement.emailErrorReason
     , invoiceStatement.invoiceStatementFinalizedDate
     , invoiceStatement.invoiceStatementDistributionBatchID
     , invoiceStatement.rebillNumberFromInvoiceStatementID
     , invoiceStatement.rebillSuffix
     , invoiceStatement.billingProfileCorrelatedCustomText1
     , invoiceStatement.billingProfileCorrelatedCustomText2
     , invoiceStatement.billingProfileCorrelatedCustomText3
     , invoiceStatement.billingProfileCorrelatedCustomText4
     , invoiceStatement.billingProfileCorrelatedCustomText5
     , invoiceStatement.billingProfileCorrelatedCustomText6
     , invoiceStatement.billingProfileCorrelatedCustomText7
     , invoiceStatement.billingProfileCorrelatedCustomText8
     , invoiceStatement.billingProfileCorrelatedCustomText9
     , invoiceStatement.billingProfileCorrelatedCustomText10
     , invoiceStatement.billingProfileCorrelatedCustomTextBlock1
     , invoiceStatement.billingProfileCorrelatedCustomTextBlock2
     , invoiceStatement.billingProfileCorrelatedCustomTextBlock3
     , CAST(
  CASE
    WHEN credit.invoiceStatementTypeLookupID = 2 -- Credit - Reinstate
      THEN 1
    ELSE 0 END AS BIT
  )                                                                                     AS isReinstated
     , CAST(
  CASE
    WHEN credit.creditOfInvoiceStatementID IS NOT NULL THEN 1
    ELSE 0 END AS BIT
  )                                                                                     AS isCredited
     , invoiceStatement.invoiceStatementTemplateID
     , invoiceStatement.effectiveDate
     , invoiceStatement.creditOfInvoiceStatementID
     , invoiceStatement.rawInvoiceStatementNumber
     , invoiceStatement.invoiceStatementStatusLookupID
     , invoiceStatement.invoiceStatementDeliveryStatusLookupID
     , invoiceStatement.invoiceStatementMessageTemplateID
     , ISNULL(totals.lineItemTotal, 0)                                                  AS 'lineItemTotal'
     , ISNULL(totals.discountTotal, 0)                                                  AS 'discountTotal'
     , ISNULL(totals.surchargeTotal, 0)                                                 AS 'surchargeTotal'
     , CASE
         WHEN invoiceStatement.isFinalized = 1
           THEN invoiceStatement.subtotal
         ELSE
               ISNULL(totals.lineItemTotal, 0)
               - ISNULL(totals.discountTotal, 0)
             + ISNULL(totals.surchargeTotal, 0)
  END                                                                                   AS 'subtotal'
     , invoiceStatement.subtotal                                                        AS 'finalizedSubtotal'
     , ISNULL(totals.taxTotal, 0)                                                       AS 'taxTotal'
     , CASE
         WHEN invoiceStatement.isFinalized = 1
           THEN invoiceStatement.total
         ELSE
               ISNULL(totals.lineItemTotal, 0)
               - ISNULL(totals.discountTotal, 0)
             + ISNULL(totals.surchargeTotal, 0)
             + ISNULL(totals.taxTotal, 0)
  END                                                                                   AS 'total'
     , invoiceStatement.total                                                           AS 'finalizedTotal'
     , invoiceStatement.generalLedgerExportStatusLookupID
     , CASE
         WHEN invoiceStatement.deliveryMethodLookupID = 3 -- Email
           THEN CASE
                  WHEN emailBatch.batchStatusLookupID IN (1, 2) -- email is Initiated, Processing
                    THEN 6 -- Email Sending
                  WHEN exportBatch.batchStatusLookupID IN (1, 2) -- exportBatch is Initiated, Processing
                    THEN 5 -- Export Generating
                  WHEN exportBatch.batchStatusLookupID = 3 AND emailBatch.batchStatusLookupID = 3 -- Completed
                    THEN 3 -- Email sent
                  WHEN exportBatch.batchStatusLookupID = 4
                    THEN 4 -- Export Generation Failed
                  WHEN export.fileSize > 10485760 OR emailBatch.emailTooLarge = 1
                    THEN 9 -- Export is Too Large for Email
                  WHEN exportBatch.batchStatusLookupID = 3 AND emailBatch.batchStatusLookupID = 4
                    THEN 2 -- Email failed
                  WHEN invoiceStatement.isFinalized = 1 AND exportBatch.batchStatusLookupID = 3 AND
                       emailBatch.batchStatusLookupID IS NULL
                    THEN 2 -- Email Not Sent
                  ELSE 1 -- N/A
           END
         WHEN invoiceStatement.deliveryMethodLookupID = 1 --Print
           THEN CASE
                  WHEN exportBatch.batchStatusLookupID IN (1, 2) -- Initiated, Processing
                    THEN 5 -- Export Generating
                  WHEN exportBatch.batchStatusLookupID = 4
                    THEN 4 -- Failed
                  WHEN export.fileSize > 41943040
                    THEN 8 -- Export is Too Large for Download
                  WHEN exportBatch.batchStatusLookupID = 3
                    THEN 7 -- Ready to print
                  ELSE 1 -- N/A
           END
         WHEN invoiceStatement.deliveryMethodLookupID = 2 --Do not Print
           THEN 1 -- N/A
         ELSE 1 -- N/A
  END                                                                                   AS newInvoiceStatementDeliveryStatusLookupID
     , CASE
         WHEN invoiceStatement.total <= invoicePayment.amountPaid
           THEN 1 -- Paid
         WHEN invoiceStatement.total > invoicePayment.amountPaid AND invoicePayment.amountPaid > 0
           THEN 2 -- Partial Paid
         ELSE
           3 -- Unpaid
  END                                                                                   AS invoiceStatementPaidStatusID
     , ISNULL(invoicePayment.paymentCount, 0)                                           AS paymentCount
     , ISNULL(invoicePayment.amountPaid, 0.00)                                          AS amountPaid
     , (ISNULL(invoiceStatement.total, 0.00) - ISNULL(invoicePayment.amountPaid, 0.00)) AS outstandingBalance
FROM BULLHORN1.BH_InvoiceStatement invoiceStatement WITH (NOLOCK)
       LEFT JOIN (
  SELECT exportBatch.invoiceStatementID, exportBatch.batchStatusLookupID
  FROM BULLHORN1.BH_InvoiceStatementExportBatch exportBatch WITH (NOLOCK)
         -- get latest invoiceStatementExportBatch based on dateLastModified or ID
         LEFT JOIN BULLHORN1.BH_InvoiceStatementExportBatch exportBatch2 WITH (NOLOCK)
                   ON exportBatch2.invoiceStatementID = exportBatch.invoiceStatementID
                     AND ((exportBatch2.dateLastModified > exportBatch.dateLastModified) OR
                          (exportBatch2.dateLastModified = exportBatch.dateLastModified AND
                           exportBatch2.invoiceStatementExportBatchID > exportBatch.invoiceStatementExportBatchID))
  WHERE exportBatch2.invoiceStatementExportBatchID IS NULL
) exportBatch ON exportBatch.invoiceStatementID = invoiceStatement.invoiceStatementID
       LEFT JOIN (
  SELECT export.invoiceStatementID, export.invoiceStatementExportID, export.fileSize
  FROM BULLHORN1.BH_InvoiceStatementExport export WITH (NOLOCK)
         -- get latest invoiceStatementExport based on dateLastModified or ID
         LEFT JOIN BULLHORN1.BH_InvoiceStatementExport export2 WITH (NOLOCK)
                   ON export2.invoiceStatementID = export.invoiceStatementID
                     AND ((export2.dateLastModified > export.dateLastModified) OR
                          (export2.dateLastModified = export.dateLastModified AND
                           export2.invoiceStatementExportID > export.invoiceStatementExportID))
  WHERE export2.invoiceStatementExportID IS NULL
) export ON export.invoiceStatementID = invoiceStatement.invoiceStatementID
       LEFT JOIN (
  SELECT export1.invoiceStatementID
       , CASE
           WHEN (COUNT(CASE WHEN emailBatch.batchStatusLookupID = 3 THEN 1 ELSE NULL END)) >= 1 THEN 3
           WHEN (COUNT(CASE WHEN emailBatch.batchStatusLookupID = 2 THEN 1 ELSE NULL END)) >= 1 THEN 2
           WHEN (COUNT(CASE WHEN emailBatch.batchStatusLookupID = 1 THEN 1 ELSE NULL END)) >= 1 THEN 1
           WHEN (COUNT(CASE WHEN emailBatch.batchStatusLookupID = 4 THEN 1 ELSE NULL END)) >= 1 THEN 4
    END as batchStatusLookupID
       , CASE
           WHEN (COUNT(CASE WHEN emailBatch.emailTooLarge = 0 THEN 1 ELSE NULL END)) >= 1 THEN 0
           WHEN (COUNT(CASE WHEN emailBatch.emailTooLarge = 1 THEN 1 ELSE NULL END)) >= 1 THEN 1
    END as emailTooLarge
       --Check if the emailBatch is completed for any export, then processing, then initiated and lastly if it failed for all attempts
  FROM BULLHORN1.BH_InvoiceStatementEmailBatch emailBatch WITH (NOLOCK)
         INNER JOIN BULLHORN1.BH_InvoiceStatementExport export1 WITH (NOLOCK)
                    ON export1.invoiceStatementExportID = emailBatch.invoiceStatementExportID
  GROUP BY export1.invoiceStatementID
) emailBatch ON emailBatch.invoiceStatementID = invoiceStatement.invoiceStatementID
       LEFT JOIN (
  SELECT lineItemTotal.invoiceStatementID,
         ISNULL(lineItemTotal.value, 0)      AS 'lineItemTotal',
         ISNULL(subtotals.discountTotal, 0)  AS 'discountTotal',
         ISNULL(subtotals.surchargeTotal, 0) AS 'surchargeTotal',
         SUM(CASE
               WHEN ist.invoiceStatementTaxID IS NULL
                 THEN ISNULL(v2TaxAmount.taxAmount, 0)
               WHEN ist.finalizedValue IS NOT NULL
                 THEN ist.finalizedValue
               WHEN tax.taxTypeID = 1 -- Fixed
                 THEN ROUND(ISNULL(tax.value, 0), ISNULL(subtotals.currencyUnitMinorUnits, 2))
               WHEN tax.taxTypeID = 2 -- Percentage
                 THEN ROUND(ISNULL(tax.value, 0) *
                            (ISNULL(lineItemTotal.value, 0) - ISNULL(subtotals.discountTotal, 0) +
                             ISNULL(subtotals.surchargeTotal, 0)), ISNULL(subtotals.currencyUnitMinorUnits, 2))
           END
           )                                 AS 'taxTotal',
         subtotals.currencyUnitMinorUnits
  FROM (
         SELECT invoiceStatementID, SUM(ISNULL(total, 0)) AS value
         FROM BULLHORN1.BH_InvoiceStatementLineItem WITH (NOLOCK)
         GROUP BY invoiceStatementID
       ) AS lineItemTotal
         JOIN (SELECT invoiceStatementID
                    , taxAmount
               FROM BULLHORN1.BH_InvoiceStatement WITH (NOLOCK)
  ) v2TaxAmount ON v2TaxAmount.invoiceStatementID = lineItemTotal.invoiceStatementID
         LEFT JOIN BULLHORN1.BH_InvoiceStatementTax ist WITH (NOLOCK)
                   ON ist.invoiceStatementID = lineItemTotal.invoiceStatementID AND ist.isDeleted = 0
         LEFT JOIN BULLHORN1.BH_Tax tax WITH (NOLOCK) ON ist.taxID = tax.taxID
         LEFT JOIN (
    SELECT discountTotal.invoiceStatementID,
           discountTotal.lineItemTotal,
           ISNULL(discountTotal.value, 0) AS 'discountTotal',
           SUM(CASE
                 WHEN iss.invoiceStatementSurchargeID IS NULL
                   THEN ISNULL(discountTotal.surchargeAmount, 0)
                 ELSE CASE
                        WHEN iss.finalizedValue IS NOT NULL
                          THEN iss.finalizedValue
                        WHEN surcharge.surchargeTypeID = 1 -- Fixed
                          THEN ROUND(ISNULL(surcharge.value, 0), ISNULL(discountTotal.currencyUnitMinorUnits, 2))
                        WHEN surcharge.surchargeTypeID = 2 -- Percentage
                          THEN ROUND(ISNULL(surcharge.value, 0) * ISNULL(discountTotal.lineItemTotal, 0),
                                     ISNULL(discountTotal.currencyUnitMinorUnits, 2))
                        ELSE 0
                   END
             END)                         AS 'surchargeTotal',
           discountTotal.currencyUnitMinorUnits
    FROM (
           SELECT lineItemTotal.invoiceStatementID,
                  ISNULL(lineItemTotal.value, 0)                   AS 'lineItemTotal',
                  SUM(
                      CASE
                        WHEN isd.finalizedValue IS NOT NULL
                          THEN isd.finalizedValue
                        WHEN discount.discountTypeID = 1 -- Fixed
                          THEN ROUND(ISNULL(discount.value, 0), ISNULL(currencyUnit.minorUnits, 2))
                        WHEN discount.discountTypeID = 2 -- Percentage
                          THEN ROUND(ISNULL(discount.value, 0) * ISNULL(lineItemTotal.value, 0),
                                     ISNULL(currencyUnit.minorUnits, 2))
                        ELSE 0
                        END
                      + ROUND(ISNULL(invoiceStatement.discountAmount, 0), ISNULL(currencyUnit.minorUnits, 2))
                    )                                              AS 'value',
                  currencyUnit.minorUnits                          AS 'currencyUnitMinorUnits',
                  SUM(ISNULL(invoiceStatement.surchargeAmount, 0)) AS surchargeAmount
           FROM (
                  SELECT invoiceStatementID, SUM(ISNULL(total, 0)) AS value
                  FROM BULLHORN1.BH_InvoiceStatementLineItem WITH (NOLOCK)
                  GROUP BY invoiceStatementID
                ) AS lineItemTotal
                  JOIN BULLHORN1.BH_InvoiceStatement invoiceStatement WITH (NOLOCK)
                       ON invoiceStatement.invoiceStatementID = lineItemTotal.invoiceStatementID
                  JOIN BULLHORN1.BH_CurrencyUnit currencyUnit
                       ON currencyUnit.currencyUnitID = invoiceStatement.currencyUnitID
                  LEFT JOIN BULLHORN1.BH_InvoiceStatementDiscount isd WITH (NOLOCK)
                            ON isd.invoiceStatementID = lineItemTotal.invoiceStatementID
                  LEFT JOIN BULLHORN1.BH_Discount discount WITH (NOLOCK) ON discount.discountID = isd.discountID
           GROUP BY lineItemTotal.invoiceStatementID, lineItemTotal.value, currencyUnit.minorUnits
         ) AS discountTotal
           LEFT JOIN BULLHORN1.BH_InvoiceStatementSurcharge iss WITH (NOLOCK)
                     ON iss.invoiceStatementID = discountTotal.invoiceStatementID
           LEFT JOIN BULLHORN1.BH_Surcharge surcharge WITH (NOLOCK) ON surcharge.surchargeID = iss.surchargeID
    GROUP BY discountTotal.invoiceStatementID, discountTotal.lineItemTotal, discountTotal.value,
             discountTotal.currencyUnitMinorUnits
  ) AS subtotals ON subtotals.invoiceStatementID = lineItemTotal.invoiceStatementID
  GROUP BY lineItemTotal.invoiceStatementID, lineItemTotal.value, subtotals.discountTotal, subtotals.surchargeTotal,
           subtotals.currencyUnitMinorUnits, v2TaxAmount.taxAmount
) AS totals ON totals.invoiceStatementID = invoiceStatement.invoiceStatementID
       LEFT JOIN BULLHORN1.BH_InvoiceStatement credit WITH (NOLOCK)
                 ON credit.creditOfInvoiceStatementID = invoiceStatement.invoiceStatementID
       LEFT JOIN (
  SELECT invoiceStatementID AS 'invoiceStatementID', SUM(amount) AS 'amountPaid', COUNT(checkNumber) AS 'paymentCount'
  FROM BULLHORN1.BH_InvoicePayment invoicePayment WITH (NOLOCK)
  GROUP BY invoiceStatementID)
  AS invoicePayment ON invoicePayment.invoiceStatementID = invoiceStatement.invoiceStatementID
;
