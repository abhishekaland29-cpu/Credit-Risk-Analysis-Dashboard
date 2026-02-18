USE Banking_DB;


# 1.Total Portfolio Exposure: What is the total amount of credit disbursed by the bank?

SELECT SUM(LOAN) AS Total_Loan FROM hmeq;

# The TOTAL LOAN DISBURSED = 221807000.00

# 2.What is the percentage of applicants who defaulted on their loans?

SELECT ROUND(AVG(BAD) * 100, 2) AS Default_Percentage FROM hmeq;

	 # The TOTAL DEFAULTER (PERCENTAGE) = 19.95%
	
# 3.Average loan amount for Defaulters vs. Non-Defaulters.

SELECT 
    CASE 
        WHEN BAD = 1 THEN 'Defaulter' 
        WHEN BAD = 0 THEN 'Non-Defaulter' 
        ELSE 'Status Unknown (NULL)' 
    END AS Loan_Status,
    COUNT(*) AS Number_of_Customers,
    ROUND(AVG(LOAN), 2) AS Avg_Loan_Amount
FROM hmeq
GROUP BY BAD;

     # Average loan amount
	 #   Defaulters (1) = 2378 = 16922.1194
	 #   Non-Defaulters (0) = 9542 = 19028.1073

# 4.Identifying the unique job sectors the bank serves.

SELECT DISTINCT JOB FROM hmeq;

	 # The JOB are DISTINCTED as 
     # Other , Office , Mgr , ProfExe , Sales , Unknown , Self

# 5.Distribution of applications based on the reason for the loan.

SELECT REASON, COUNT(*) AS Total_Applications FROM hmeq
GROUP BY REASON;

     # 5.Distribution of applications based on the reason are as follows:
     #    HomeImp = 3560
     #    DebtCon = 504
     #    Unknown = 7856
     
# 6.Identifying technical indicators that lead to high-risk loan applications.

SELECT 
    CASE 
        WHEN DEBTINC IS NULL THEN 'Missing DTI' 
        ELSE 'Has DTI Data' 
    END AS DTI_Status, 
    COUNT(*) AS Total_Customers,
    ROUND(AVG(BAD) * 100, 2) AS Default_Rate_Percentage
FROM hmeq
GROUP BY 1;

     # OUTPUT : DTI_Missing Data (1) = TOTAL CUSTOMER (2534) = Default_Rate ( 62.04%)
     #          DTI_Missing Data (0) = TOTAL CUSTOMER (9386) = Default_Rate ( 8.59%)
     
# 7.Determining at what point the number of delinquent accounts significantly increases default probability

SELECT 
    COALESCE(CAST(DELINQ AS CHAR), 'Missing/NULL') AS Delinquent_Lines, 
    COUNT(*) AS Total_Customers,
    ROUND(AVG(BAD) * 100, 2) AS Risk_Probability_Percentage
FROM hmeq
GROUP BY DELINQ 
ORDER BY DELINQ;

     # Delinquent Accounts (Points) vs Risk Probability
     # 0 (Cust:9518)--> 13.76% , 1 (Cust:9518)--> 33.94% , 2 (Cust:9518)--> 44.80% , 3 (Cust:9518)--> 55.04% , 4 (Cust:9518)--> 58.97%
     # 5 (Cust:9518)--> 81.58 , (6 , 7 , 8 , 10, 11, 12, 13, 15) (Cust:54,26,10,4,4,2,2,2)--> 1.0000
     
# 8.Impact of serious past credit defaults on current loan performance.

SELECT 
    COALESCE(CAST(DEROG AS CHAR), 'No Data') AS Derogatory_Reports, 
    COUNT(*) AS Total_Applicants, 
    SUM(BAD) AS Total_Defaulters,
    ROUND((SUM(BAD) / COUNT(*)) * 100, 2) AS Default_Rate_Percentage
FROM hmeq
GROUP BY DEROG
ORDER BY DEROG ASC;

     #Impact of serious past credit defaults
     # 1.Low Risk (DEROG = 0):
     #          10470 Applicants ---> 1682 Defaulters ---> Default Rate : 16.06%
     # 2.High Risk Zone (DEROG 1 to 3):
     #          DEROG 1: 870 Applicants ---> 338 Defaulters ---> Default Rate: 38.85%
     #          DEROG 2: 320 Applicants ---> 164 Defaulters ---> Default Rate: 51.25%
     #          DEROG 3: 116 Applicants ---> 86 Defaulters ---> Default Rate: 74.14%
     # 3.Dead Zone (DEROG 4 to 10):
     #          DEROG 4: 46 Applicants ---> 36 Defaulters ---> Default Rate: 78.26%
     #          DEROG 6: 30 Applicants ---> 20 Defaulters ---> Default Rate: 66.67%
     #          DEROG 7 to 10 --> (Default Rate: 100%).
     
# 9.Identifying cases where the loan amount exceeds the property value (LTV > 1).

SELECT COUNT(*) AS High_LTV_Defaulters 
FROM hmeq
WHERE (LOAN / NULLIF(VALUE, 0)) > 1 AND BAD = 1;

      # TOTAL DEFAULTER WITH HIGH LTV = 4
      
# 10.Relationship between recent credit inquiries (NINQ) and the likelihood of default.

SELECT 
    IFNULL(CAST(NINQ AS CHAR), 'No Data') AS Inquiries, 
    COUNT(*) AS Applicants, 
    SUM(BAD) AS Defaulters,
    ROUND(AVG(BAD) * 100, 2) AS Default_Rate
FROM hmeq
GROUP BY NINQ
ORDER BY NINQ ASC;

      # Case 1 --> NINQ = 0 to 6
      #            risk = 15.49% to 51.79% (With constant growth of 3% to 5% )
      # Case 2 --> NINQ = 7 to 10
      #            risk = 32.14% to 54.55%
      # Case 3 --> NINQ = 11 to 17#            risk = [ For 11 = 30.00% ] , [ For 12 - 17 = 100.00%]

# 11.Ranking professions based on their default rates.

SELECT 
    COALESCE(JOB, 'Not Disclosed') AS Profession, 
    COUNT(*) AS Total_Applicants, 
    SUM(BAD) AS Total_Defaulters,
    ROUND(AVG(BAD) * 100, 2) AS Default_Rate_Percentage
FROM hmeq
GROUP BY JOB
ORDER BY Default_Rate_Percentage DESC;
	
       #  HIGH DEFAULT RATE ( approx 34.86% - 35.0% ) = "Sales" (34.86%) & "Self-Employed" (30.05%)
       #  MID DEFAULT RATE  ( approx 23.2% - 23.4% ) = "Mgr" And "Oters"
       #  LESS DEFAULT RATE( approx 13.0% - 16.6%) = "ProfExe" and "Office" 
       
# 12.Determining if "Years on Job" (YOJ) influences repayment behavior.

SELECT 
    CASE 
        WHEN YOJ IS NULL THEN 'Unknown'
        WHEN YOJ < 2 THEN 'Newbie (0-2 Yrs)' 
        WHEN YOJ BETWEEN 2 AND 10 THEN 'Experienced (2-10 Yrs)' 
        ELSE 'Veteran (10+ Yrs)' 
    END AS Job_Tenure, 
    COUNT(*) AS Applicants,
    ROUND(AVG(BAD) * 100, 2) AS Default_Rate_Percentage
FROM hmeq 
GROUP BY 1
ORDER BY FIELD(Job_Tenure, 'Newbie (0-2 Yrs)', 'Experienced (2-10 Yrs)', 'Veteran (10+ Yrs)', 'Unknown');

        # Influence Of Years Of Job on Repayment Behaviour
        # High to Mid Risk :
        #     Newbie (0-2 Yrs): [ Risk: 21.71% ]
        #     Experienced (2-10 Yrs): [ Risk: 21.66% ]
        # Medium Risk :
        #     Veteran (10+ Yrs): [ Risk: 18.52% ]
        # Lowest Risk :
        #     Unknown/Missing: [ Risk: 12.62% ]
        
# 13.Categorizing risk based on the applicant's DTI ratio.

SELECT 
    CASE 
        WHEN DEBTINC IS NULL THEN 'Missing Data'
        WHEN DEBTINC < 30 THEN 'Safe Zone (<30)' 
        WHEN DEBTINC BETWEEN 30 AND 45 THEN 'Warning Zone (30-45)' 
        ELSE 'High Risk Zone (>45)' 
    END AS DTI_Category, 
    COUNT(*) AS Total_Applicants,
    ROUND(AVG(BAD) * 100, 2) AS Default_Rate_Percentage
FROM hmeq
GROUP BY 1
ORDER BY FIELD(DTI_Category, 'Safe Zone (<30)', 'Warning Zone (30-45)', 'High Risk Zone (>45)', 'Missing Data');

         # DTI Category --> 1.Warning Zone   = Applicant (6740) --> 7.74% (Default Rate)
         #                  2.Safe Zone	     = Applicant5 (2496) --> 4.45% (Default Rate)
		 #                  3.High Risk Zone = Applicant (150) --> 98.67% (Default Rate)
         #                  3.Missing Data   = Applicant (2534) --> 62.04% (Default Rate)
         
# 14.Average mortgage due per profession.

SELECT JOB, AVG(MORTDUE) AS Avg_Mortgage_Due FROM hmeq
GROUP BY JOB;

		 # Mortgage Due v/s Proffession (JOB)
         # 1. HIGH (From 80k - 100k and above):
         #      Self-Employed: $99,776.19
         #      ProfExe (Professional/Executive): $94,959.64
         #      Mgr (Manager): $82,295.01
         #      Sales: $82,266.18
         # 2. Less ( From 60k - 69k ) :
         #      Office: $66,757.14
         #      Unknown: $62,687.31
         #      Other: $59,337.15         
		
# 15.Total property value of all defaulted accounts.

SELECT 
    COUNT(*) AS Total_Defaulters,
    SUM(LOAN) AS Total_Loss_Amount,
    SUM(VALUE) AS Total_Collateral_Value_at_Risk,
    ROUND(AVG(VALUE), 2) AS Avg_Property_Value_of_Defaulter
FROM hmeq 
WHERE BAD = 1;

		 # TOTAL Loss Amount = 40240800.00/-
         # TOTAL PROPERTY OF DEFAULTER = 212838732.00/-
         # AVG PROPERTY OF DEFAULTER = 98172.85/-
         
# 16.Identifying loan amounts that significantly exceed the portfolio average.

SELECT 
    BAD, 
    LOAN, 
    VALUE, 
    JOB, 
    DEROG,
    (LOAN / NULLIF(VALUE, 0)) AS LTV_Ratio 
FROM hmeq
WHERE LOAN > (SELECT AVG(LOAN) * 3 FROM hmeq)
ORDER BY LOAN DESC;

         # 1.Total Outliers Identified: 114
         # 2.Default Behavior: Surprisingly, 90.35% of high-value borrowers are Non-Defaulters (BAD = 0).
         # 3.Risk vs. Collateral: In many cases, the LTV Ratio is > 1.0 (meaning the loan is higher than the house value),
         #                        yet these borrowers are repaying consistently.
         # 4.Customer Profile: Most of these applicants belong to 'Self', 'ProfExe', or 'Office' categories 
         #                     with a very long credit history (CLAGE > 100 months).

# 17.Identifying top applicants with multiple red flags (DTI, Delinquency, and Derogatory reports).

SELECT * FROM hmeq WHERE DELINQ > 2 AND DEROG > 2 AND BAD = 1 LIMIT 5;

	/*   1. Default Correlation:
                  Observation: Out of the top 5 high-risk profiles, 80% resulted in Default (BAD = 1).
                  Key Insight: When multiple red flags are present, the probability of repayment drops significantly,
                               regardless of the applicant's job title or tenure.
		 2. The "Warning Sign" Pattern:
                  Delinquency (DELINQ): Most applicants had 3 to 6 instances of late payments.
                  Derogatory Reports (DEROG): Every applicant in this list had 3 to 5 past legal/credit defaults.
                  Insight: A history of repeated credit mismanagement is the strongest predictor of future failure.
		 3. Professional Stability vs. Credit Discipline:
				  Job Tenure (YOJ): These applicants have stable jobs (between 5 to 13 years).
                  The Irony: Even with "Veteran" and "Experienced" job status (Managers and Office staff), 
							 their lack of credit discipline led to default.
                  Conclusion: Employment stability cannot compensate for a poor credit history.
		 4. Strategic Policy Recommendation:
                  Automatic Rejection: The bank should implement a "Hard Reject" rule for any applicant 
									   where DEROG > 2 and DELINQ > 2.
				  Loan Purpose: Interestingly, all identified toxic profiles were for Home Improvement loans, 
                                suggesting a need for stricter auditing in this category.
	*/


# 18. Refined: Impact of Credit Line Age on Default Probability

SELECT 
    ROUND(CLAGE/12, 0) AS Credit_Years, 
    COUNT(*) AS Total_Applicants, 
    SUM(BAD) AS Defaulters,
    ROUND(AVG(BAD) * 100, 2) AS Risk_Percentage
FROM hmeq 
WHERE CLAGE IS NOT NULL
GROUP BY 1 
ORDER BY 1;

     /* # 1.High-Risk --> 0–10 Years --> 18% - 27% [ default rates ]
        # 2.Stabilized-Risk --> 11–20 Years --> 12.2% to 26.8% [ default rates ]
        # 3.Less Risk --> 21–30 Years --> 6.0% to 11.0% [ default rates ]
        # 4.Zero Risk --> Legacy Credit: 31–54 Years --> Mostly 0% [ default rates ]
         NOTE : There are a few outliers at the very end (Years 96 and 97) showing 100% risk, 
         but since the sample size is only 2 people, this is a statistical anomaly
     */

# 19.Total loan distribution by Reason and Status.

SELECT 
    COALESCE(REASON, 'Unknown') AS Loan_Purpose, 
    CASE WHEN BAD = 0 THEN 'Active/Paid' ELSE 'Defaulted' END AS Loan_Status,
    COUNT(*) AS Number_of_Loans,
    SUM(LOAN) AS Total_Capital_Allocated,
    ROUND(SUM(LOAN) * 100.0 / SUM(SUM(LOAN)) OVER(), 2) AS Portfolio_Share_Percentage
FROM hmeq
GROUP BY REASON, BAD
ORDER BY Loan_Purpose, BAD;

       /*  1. Debt Consolidation (The Heavy Hitter):
                     Active/Paid: $128,442,800 (57.91%)
                     Defaulted: $28,307,600 (12.76%)
	       2. Home Improvement (Secondary Focus):
					 Active/Paid: $46,908,800 (21.15%)
                     Defaulted: $10,074,800 (4.54%)
		   3. Unknown / Uncategorized:
                     Active/Paid: $6,214,600 (2.80%)
                     Defaulted: $1,858,400 (0.84%)
       */

# 20. Refined: Categorizing Risk by Number of Credit Lines

SELECT 
    CASE 
        WHEN CLNO <= 10 THEN 'Few (0-10)'
        WHEN CLNO BETWEEN 11 AND 30 THEN 'Average (11-30)' 
        ELSE 'Many (30+)' 
    END AS Credit_Line_Bucket,
    COUNT(*) AS Total_Applicants,
    ROUND(AVG(BAD) * 100, 2) AS Risk_Percentage
FROM hmeq
GROUP BY 1
ORDER BY Risk_Percentage DESC;

/* 1. HIGH RISK: The "Thin Files" (Few 0–10 Lines):
                 Risk Percentage: 28.80%
                 Total Applicants: 1,382

2. MEDIUM RISK: The "Over-Leveraged" (Many 30+ Lines):
                 Risk Percentage: 22.94%
                 Total Applicants: 2,302

3. LOW RISK: The "Sweet Spot" (Average 11–30 Lines):
                 Risk Percentage: 17.63%
                 Total Applicants: 8,236 
/*
