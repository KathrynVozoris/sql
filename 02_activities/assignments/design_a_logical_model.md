# Assignment 1: Design a Logical Model

## Question 1
Create a logical model for a small bookstore. 📚

At the minimum it should have employee, order, sales, customer, and book entities (tables). Determine sensible column and table design based on what you know about these concepts. Keep it simple, but work out sensible relationships to keep tables reasonably sized. Include a date table. There are several tools online you can use, I'd recommend [_Draw.io_](https://www.drawio.com/) or [_LucidChart_](https://www.lucidchart.com/pages/).


![Katthryn_Vozoris_sql_assignment_1](https://github.com/user-attachments/assets/8af77f7d-d460-4fb7-b43f-7abdd17d27be)


## Question 2!

We want to create employee shifts, splitting up the day into morning and evening. Add this to the ERD.

See above file.

## Question 3
The store wants to keep customer addresses. Propose two architectures for the CUSTOMER_ADDRESS table, one that will retain changes, and another that will overwrite. Which is type 1, which is type 2?

_Hint, search type 1 vs type 2 slowly changing dimensions._

Bonus: Are there privacy implications to this, why or why not?
```
Type 2 will make the change and retain the history of what was there before. Type 1 will simply overwrite and not retain any data history. Retaining the historical information has privacy implications. The additional historical address information creates an increased risk of identity theft to the customer, should a data breach occur.
```

## Question 4
Review the AdventureWorks Schema [here](https://i.stack.imgur.com/LMu4W.gif)

Highlight at least two differences between it and your ERD. Would you change anything in yours?
```
In the AdventureWorkds Schema, they have added colour coded sections to identify general categories-- sales, purchasing, person, production and human resources.

The table I produced had an 'Orders' table, which contains order details including the 'Ship to address'. In the Adventureworkds Schema the 'SalesOrderHeader' table does not include a 'Ship to address' column, but instead holds a 'Ship to address id' column. This table then points to an 'Address' table, holding the address that includes a 'State/Province id' (but not the name of the state/province, or country name). To get the state or province associated with the address, we are pointed to a third table titled "State/Province" which holds the state or province name and a 'country id' column. This table then points to a fourth table 'Country/Region' which also has a'country id' column, and the country name.

I would include seprate columns instead of simply using "Address' as they did, e.g. 'address line 1', 'address line 2', 'postal code/zip code', 'state/province' and 'country'. I would also include the idea of a general 'Address' table, with an 'Address id" key, which could hold the addresses of customers, employees, and ship to adresses. This would connect to the 'Employees' table, 'Customers' table, and 'Orders' table.
```

# Criteria

[Assignment Rubric](./assignment_rubric.md)

# Submission Information

🚨 **Please review our [Assignment Submission Guide](https://github.com/UofT-DSI/onboarding/blob/main/onboarding_documents/submissions.md)** 🚨 for detailed instructions on how to format, branch, and submit your work. Following these guidelines is crucial for your submissions to be evaluated correctly.

### Submission Parameters:
* Submission Due Date: `September 28, 2024`
* The branch name for your repo should be: `model-design`
* What to submit for this assignment:
    * This markdown (design_a_logical_model.md) should be populated.
    * Two Entity-Relationship Diagrams (preferably in a pdf, jpeg, png format).
* What the pull request link should look like for this assignment: `https://github.com/<your_github_username>/sql/pull/<pr_id>`
    * Open a private window in your browser. Copy and paste the link to your pull request into the address bar. Make sure you can see your pull request properly. This helps the technical facilitator and learning support staff review your submission easily.

Checklist:
- [ ] Create a branch called `model-design`.
- [ ] Ensure that the repository is public.
- [ ] Review [the PR description guidelines](https://github.com/UofT-DSI/onboarding/blob/main/onboarding_documents/submissions.md#guidelines-for-pull-request-descriptions) and adhere to them.
- [ ] Verify that the link is accessible in a private browser window.

If you encounter any difficulties or have questions, please don't hesitate to reach out to our team via our Slack at `#cohort-4-help`. Our Technical Facilitators and Learning Support staff are here to help you navigate any challenges.
