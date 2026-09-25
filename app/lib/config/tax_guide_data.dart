class TaxGuideEntry {
  final String title;
  final String overview;
  final String details;
  final String pitfall;
  final String sourceTitle;
  final String sourceUrl;

  const TaxGuideEntry({
    required this.title,
    required this.overview,
    required this.details,
    required this.pitfall,
    required this.sourceTitle,
    required this.sourceUrl,
  });

  String get checklistId => title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}

class TaxGuideData {
  static const reviewedDate = 'July 23, 2026';

  static const scheduleCUrl = 'https://www.irs.gov/instructions/i1040sc';
  static const pub334Url = 'https://www.irs.gov/publications/p334';
  static const pub463Url = 'https://www.irs.gov/publications/p463';
  static const pub587Url = 'https://www.irs.gov/publications/p587';
  static const pub946Url = 'https://www.irs.gov/publications/p946';
  static const recordkeepingUrl =
      'https://www.irs.gov/businesses/small-businesses-self-employed/recordkeeping';
  static const mileageUrl =
      'https://www.irs.gov/tax-professionals/standard-mileage-rates';
  static const healthInsuranceUrl = 'https://www.irs.gov/instructions/i7206';
  static const retirementUrl = 'https://www.irs.gov/publications/p560';
  static const qbiUrl = 'https://www.irs.gov/irb/2025-45_IRB';

  static const expenseEntries = <TaxGuideEntry>[
    TaxGuideEntry(
      title: 'Advertising and marketing',
      overview:
          'Ads, websites, promotional materials and ordinary marketing costs may qualify.',
      details:
          'Keep the invoice, campaign or vendor, payment proof and the business being promoted. Meals distributed to the general public as advertising can follow different meal-limit rules.',
      pitfall:
          'Political contributions and lobbying are generally not business deductions. Sponsorships need a real business promotion purpose.',
      sourceTitle: 'IRS Publication 334 — Other expenses',
      sourceUrl: pub334Url,
    ),
    TaxGuideEntry(
      title: 'Office expenses, supplies and software',
      overview:
          'Consumable supplies, office costs and business software may qualify.',
      details:
          'Examples include paper, postage, small tools, cloud services, bookkeeping software and professional subscriptions used in the business.',
      pitfall:
          'Property with a useful life beyond the year may need capitalization, depreciation or a valid safe-harbor election instead of an immediate expense.',
      sourceTitle: 'IRS Schedule C instructions — Lines 18 and 22',
      sourceUrl: scheduleCUrl,
    ),
    TaxGuideEntry(
      title: 'Contract labor, commissions and wages',
      overview:
          'Ordinary payments for people who help operate the business may qualify.',
      details:
          'Schedule C separates commissions and fees, contract labor, and employee wages. Preserve contracts, invoices, payment records and worker classification support.',
      pitfall:
          'Calling a worker a contractor does not make them one. Information-return, payroll and employment-tax duties may apply.',
      sourceTitle: 'IRS Schedule C instructions — Lines 10, 11 and 26',
      sourceUrl: scheduleCUrl,
    ),
    TaxGuideEntry(
      title: 'Employee benefits and retirement contributions',
      overview:
          'Qualifying employee benefit programs and employer retirement contributions may be deductible.',
      details:
          'Schedule C separately reports employee benefit programs and pension or profit-sharing plans. Preserve plan documents, payroll records and contribution support.',
      pitfall:
          'The owner’s own health-insurance and retirement deductions generally belong on Schedule 1, not these Schedule C lines.',
      sourceTitle: 'IRS Schedule C instructions — Lines 14 and 19',
      sourceUrl: scheduleCUrl,
    ),
    TaxGuideEntry(
      title: 'Rent and leases',
      overview:
          'Business rent for workspace, vehicles, machinery or equipment may qualify.',
      details:
          'Deduct only the business portion. Advance rent is generally allocated to the period it covers. Long vehicle leases can require an inclusion amount.',
      pitfall:
          'Payments that build ownership or equity are not rent, and personal-use portions must be separated.',
      sourceTitle: 'IRS Publication 334 — Rent expense',
      sourceUrl: pub334Url,
    ),
    TaxGuideEntry(
      title: 'Utilities, phone and internet',
      overview:
          'The business share of utilities and communications may qualify.',
      details:
          'Track a reasonable business-use allocation for mixed-use mobile, internet and home utilities. A second line used exclusively for business may qualify.',
      pitfall:
          'The base charge for the first landline into a residence is personal. A receipt for a family plan does not prove the business percentage.',
      sourceTitle: 'IRS Publication 587 — Utilities and telephone',
      sourceUrl: pub587Url,
    ),
    TaxGuideEntry(
      title: 'Business insurance',
      overview:
          'Liability, malpractice, property and other business coverage may qualify.',
      details:
          'Publication 334 lists several qualifying business policies, including liability, malpractice and insurance on business vehicles or property.',
      pitfall:
          'Some life-insurance premiums are nondeductible when the owner is directly or indirectly a beneficiary. Prepaid multi-year coverage must be allocated.',
      sourceTitle: 'IRS Publication 334 — Insurance',
      sourceUrl: pub334Url,
    ),
    TaxGuideEntry(
      title: 'Legal, accounting and tax preparation',
      overview:
          'Professional fees directly related to operating the business may qualify.',
      details:
          'The business portion of accounting, legal advice and tax-return preparation can qualify. Keep an invoice that separates business from personal work.',
      pitfall:
          'Fees to acquire an asset are usually added to its basis. Personal work, such as a will, is not a Schedule C expense.',
      sourceTitle: 'IRS Publication 334 — Legal and professional fees',
      sourceUrl: pub334Url,
    ),
    TaxGuideEntry(
      title: 'Bank and payment-processing fees',
      overview: 'Business-account and merchant-processing fees may qualify.',
      details:
          'Preserve processor statements showing gross receipts, refunds and fees. Reconcile the gross amount to Forms 1099-K and business records.',
      pitfall:
          'Do not report only the net deposit as revenue and then forget the fee; that can understate both gross receipts and expenses.',
      sourceTitle: 'IRS Publication 334 — Other expenses',
      sourceUrl: pub334Url,
    ),
    TaxGuideEntry(
      title: 'Repairs and maintenance',
      overview: 'Work that keeps business property operating may qualify.',
      details:
          'Incidental repairs and maintenance that do not materially add value or prolong useful life can generally be current expenses.',
      pitfall:
          'Improvements, restorations and adaptations generally must be capitalized. Your own labor is not deductible.',
      sourceTitle: 'IRS Schedule C instructions — Line 21',
      sourceUrl: scheduleCUrl,
    ),
    TaxGuideEntry(
      title: 'Taxes, licenses and regulatory fees',
      overview:
          'Certain taxes and fees directly attributable to the business may qualify.',
      details:
          'Business licenses, regulatory fees, employer payroll taxes and some state or local business taxes can qualify.',
      pitfall:
          'Federal income tax is not a Schedule C deduction. Government fines for violating the law are generally nondeductible.',
      sourceTitle: 'IRS Publication 334 — Taxes',
      sourceUrl: pub334Url,
    ),
    TaxGuideEntry(
      title: 'Business interest',
      overview:
          'Interest on debt whose proceeds are used for the business may qualify.',
      details:
          'The use of the loan proceeds—not merely the collateral—generally determines the allocation. Mixed-use debt must be divided.',
      pitfall:
          'Personal-loan interest is not deductible on Schedule C, and business-interest limitations can apply.',
      sourceTitle: 'IRS Publication 334 — Interest',
      sourceUrl: pub334Url,
    ),
    TaxGuideEntry(
      title: 'Business travel',
      overview:
          'Ordinary travel away from the tax home for business may qualify.',
      details:
          'Potential items include transportation, lodging, baggage, local transportation and qualifying incidental costs. Record dates, destination and business purpose.',
      pitfall:
          'A trip must be away from the tax home and primarily business under the applicable rules. Personal days and companion costs are generally not deductible.',
      sourceTitle: 'IRS Publication 463 — Travel expenses',
      sourceUrl: pub463Url,
    ),
    TaxGuideEntry(
      title: 'Business meals',
      overview:
          'Qualifying non-entertainment business meals are generally subject to a 50% limit.',
      details:
          'The taxpayer or employee must generally be present, the meal cannot be lavish or extravagant, and a current or potential business contact must be involved when required.',
      pitfall:
          'Entertainment is generally nondeductible. Food at an entertainment event should be purchased or stated separately to be considered under the meal rules.',
      sourceTitle: 'IRS Publication 463 — Meals and entertainment',
      sourceUrl: pub463Url,
    ),
    TaxGuideEntry(
      title: 'Vehicle and local transportation',
      overview:
          'Business driving may use the standard-mileage or actual-expense method when eligible.',
      details:
          'For 2026, the IRS rate is 72.5¢ per business mile from January through June and 76¢ from July through December. Parking and tolls may be separately considered.',
      pitfall:
          'Commuting is personal. Keep mileage, date, destination and purpose. Do not combine standard mileage with the actual operating costs it replaces.',
      sourceTitle: 'IRS — 2026 standard mileage rates',
      sourceUrl: mileageUrl,
    ),
    TaxGuideEntry(
      title: 'Business gifts',
      overview:
          r'Business gifts may qualify, but the federal limit is generally $25 per recipient per year.',
      details:
          'Record the cost, date, description, business purpose and business relationship. Incidental packaging can be treated separately in limited circumstances.',
      pitfall:
          'Gifts to a customer’s family can be treated as indirect gifts to the customer. Spouses are generally treated as one taxpayer for the limit.',
      sourceTitle: 'IRS Publication 463 — Gifts',
      sourceUrl: pub463Url,
    ),
    TaxGuideEntry(
      title: 'Business use of the home',
      overview:
          'A qualifying home office may use actual expenses or the simplified method.',
      details:
          r'The space generally must be used regularly and exclusively for business and meet a qualifying-business-use test. The simplified method is generally $5 per square foot, up to 300 square feet.',
      pitfall:
          'A dual-purpose kitchen table normally fails exclusive use. The deduction and carryovers can be limited by business income.',
      sourceTitle: 'IRS Publication 587 — Business use of home',
      sourceUrl: pub587Url,
    ),
    TaxGuideEntry(
      title: 'Equipment, Section 179 and depreciation',
      overview:
          'Computers, equipment, furniture and other qualifying property may be expensed or depreciated.',
      details:
          r'For 2026, the Section 179 limit is $2.56 million with phaseout beginning above $4.09 million. Qualified property acquired after January 19, 2025 may be eligible for 100% bonus depreciation.',
      pitfall:
          'Eligibility, placed-in-service date, business-use percentage, listed-property rules and later recapture matter. A receipt alone is not enough.',
      sourceTitle: 'IRS Publication 946 — Depreciation',
      sourceUrl: pub946Url,
    ),
    TaxGuideEntry(
      title: 'Start-up costs',
      overview:
          'Certain pre-opening investigation and launch costs can receive special treatment.',
      details:
          'A limited current deduction may be available when the active business begins; remaining qualifying costs are generally amortized over 180 months.',
      pitfall:
          'Costs incurred after operations begin, asset-acquisition costs and organizational costs can follow different rules. Preserve the date active operations began.',
      sourceTitle: 'IRS Form 4562 instructions — Amortization',
      sourceUrl: 'https://www.irs.gov/instructions/i4562',
    ),
    TaxGuideEntry(
      title: 'Education and professional resources',
      overview:
          'Education that maintains or improves skills in the existing business may qualify.',
      details:
          'Potential records include course invoices, books, trade publications and a note explaining the relationship to the current business.',
      pitfall:
          'Education that qualifies someone for a new trade or business generally does not qualify as a current business expense. Club dues are generally nondeductible.',
      sourceTitle: 'IRS Publication 970 — Work-related education',
      sourceUrl: 'https://www.irs.gov/publications/p970',
    ),
    TaxGuideEntry(
      title: 'Inventory and cost of goods sold',
      overview:
          'Product costs may belong in cost of goods sold rather than a general expense category.',
      details:
          'Track beginning inventory, purchases, materials, labor where applicable, other costs and ending inventory under the accounting method that applies.',
      pitfall:
          'Do not deduct the same product cost both as supplies and cost of goods sold. Personal withdrawals are not business sales or deductible costs.',
      sourceTitle: 'IRS Schedule C instructions — Part III',
      sourceUrl: scheduleCUrl,
    ),
    TaxGuideEntry(
      title: 'Business bad debts',
      overview:
          'A debt that becomes worthless and is closely related to the business may qualify.',
      details:
          'Business bad debts commonly arise from credit sales or qualifying business-motivated loans. Document the debt, business relationship and collection efforts.',
      pitfall:
          'Cash-method businesses generally have no deduction for unpaid fees they never included in income. A capital contribution is not a loan.',
      sourceTitle: 'IRS Publication 334 — Bad debts',
      sourceUrl: pub334Url,
    ),
    TaxGuideEntry(
      title: 'Self-employed health insurance',
      overview:
          'Eligible medical, dental, vision and qualified long-term-care premiums may create a separate deduction.',
      details:
          'This owner-level deduction is generally reported on Schedule 1, not Schedule C, and may require Form 7206.',
      pitfall:
          'Eligibility for an employer-sponsored plan, business earned income and Marketplace premium-tax-credit rules can limit the amount.',
      sourceTitle: 'IRS Form 7206 instructions',
      sourceUrl: healthInsuranceUrl,
    ),
    TaxGuideEntry(
      title: 'Self-employed retirement plans',
      overview:
          'Eligible SEP, SIMPLE or qualified-plan contributions may create a separate deduction.',
      details:
          'A sole proprietor is treated as both employer and employee. Owner contributions are generally reported on Schedule 1 rather than Schedule C.',
      pitfall:
          'Contribution limits and the calculation of net earnings are plan-specific. Employee contributions and owner contributions are reported differently.',
      sourceTitle: 'IRS Publication 560 — Retirement plans',
      sourceUrl: retirementUrl,
    ),
    TaxGuideEntry(
      title: 'Deductible part of self-employment tax',
      overview:
          'An income-tax deduction is generally available for the employer-equivalent part of self-employment tax.',
      details:
          'The amount is calculated from Schedule SE and generally reported on Schedule 1. It reduces income tax but does not reduce net earnings used to calculate self-employment tax.',
      pitfall:
          'This is not a receipt expense and should not be entered as a Schedule C category.',
      sourceTitle: 'IRS Publication 334 — Self-employment tax',
      sourceUrl: pub334Url,
    ),
    TaxGuideEntry(
      title: 'Qualified business income deduction',
      overview:
          'Eligible owners may receive a deduction of up to 20% of qualified business income.',
      details:
          r'For 2026, new minimum-deduction rules can apply when qualified business income is at least $1,000. Income, business type, wages and qualified property can limit the result.',
      pitfall:
          'This is not a Schedule C receipt category, and it is not automatically 20% of gross revenue.',
      sourceTitle: 'IRS Revenue Procedure 2025-32 — 2026 QBI rules',
      sourceUrl: qbiUrl,
    ),
  ];

  static const pitfallEntries = <TaxGuideEntry>[
    TaxGuideEntry(
      title: '“Business” does not automatically mean deductible',
      overview:
          'The expense generally must be ordinary and necessary for a real trade or business.',
      details:
          'The activity should have a profit motive and be pursued with continuity and regularity. Facts and circumstances control.',
      pitfall:
          'Personal, family, hobby and living expenses generally remain nondeductible even when paid from a business account.',
      sourceTitle: 'IRS Publication 334 — Business expenses',
      sourceUrl: pub334Url,
    ),
    TaxGuideEntry(
      title: 'Some familiar costs are specifically disallowed',
      overview:
          'Charitable contributions, club dues, entertainment and several other costs are generally not Schedule C expenses.',
      details:
          'Publication 334 also identifies political contributions, lobbying, personal expenses and government fines for breaking the law as generally nondeductible business costs.',
      pitfall:
          'Paying from a business card or describing an event as networking does not override a specific disallowance.',
      sourceTitle: 'IRS Publication 334 — Expenses you cannot deduct',
      sourceUrl: pub334Url,
    ),
    TaxGuideEntry(
      title: 'A receipt does not prove business purpose',
      overview:
          'Keep amount, date, vendor and why the expense served the business.',
      details:
          'Travel, gifts, meals and transportation have heightened substantiation elements, including place, purpose and sometimes business relationship.',
      pitfall:
          'The IRS states that approximated or estimated expenses generally cannot replace adequate records.',
      sourceTitle: 'IRS Publication 463 — Recordkeeping',
      sourceUrl: pub463Url,
    ),
    TaxGuideEntry(
      title: 'Mixed business and personal use must be split',
      overview:
          'Only the supportable business portion is generally considered.',
      details:
          'This commonly affects vehicles, phones, internet, travel, home costs, subscriptions and professional fees.',
      pitfall:
          'A round percentage without a usage basis, log or other support can be difficult to substantiate.',
      sourceTitle: 'IRS Publication 334 — Business expenses',
      sourceUrl: pub334Url,
    ),
    TaxGuideEntry(
      title: 'Commuting is not business mileage',
      overview:
          'Travel between home and a regular workplace is generally personal commuting.',
      details:
          'Qualifying travel between business locations or to temporary business destinations can be treated differently.',
      pitfall:
          'Home-office qualification can affect where the business trip starts, so document the facts rather than labeling every drive “business.”',
      sourceTitle: 'IRS Publication 463 — Transportation',
      sourceUrl: pub463Url,
    ),
    TaxGuideEntry(
      title: 'Choose the vehicle method on time',
      overview:
          'The standard-mileage method has first-year and lease-period election rules.',
      details:
          'An owned car generally must use standard mileage in the first business-use year to preserve later flexibility. A leased car using it generally must continue for the lease period.',
      pitfall:
          'Section 179, bonus depreciation or certain depreciation methods can make standard mileage unavailable.',
      sourceTitle: 'IRS Publication 463 — Standard mileage',
      sourceUrl: pub463Url,
    ),
    TaxGuideEntry(
      title: 'Meals and entertainment are not the same',
      overview:
          'Qualifying meals are generally 50% limited; entertainment is generally nondeductible.',
      details:
          'Separately stated food at an entertainment event can be evaluated under the meal rules.',
      pitfall:
          'Coding the entire event receipt as “meals” does not bypass the entertainment disallowance.',
      sourceTitle: 'IRS Publication 463 — Meals and entertainment',
      sourceUrl: pub463Url,
    ),
    TaxGuideEntry(
      title: 'Expense versus asset versus inventory',
      overview:
          'The correct timing depends on what was purchased and how it is used.',
      details:
          'Current operating expenses, capital assets, improvements, start-up costs and inventory each follow different timing rules.',
      pitfall:
          'Immediate payment does not necessarily mean an immediate deduction.',
      sourceTitle: 'IRS Schedule C instructions',
      sourceUrl: scheduleCUrl,
    ),
    TaxGuideEntry(
      title: 'Prepaid costs may span tax years',
      overview:
          'Insurance, rent and services paid in advance may need allocation.',
      details:
          'Cash-method taxpayers generally deduct expenses in the proper period and cannot automatically deduct a multi-year asset in the payment year.',
      pitfall:
          'Keep the service dates or coverage period, not only the payment date.',
      sourceTitle: 'IRS Publication 334 — Accounting periods',
      sourceUrl: pub334Url,
    ),
    TaxGuideEntry(
      title: 'Reimbursements need matching treatment',
      overview:
          'Client reimbursements and the related costs must be accounted for consistently.',
      details:
          'Independent contractors should retain adequate records and understand whether reimbursements are included in income or separately accounted to the client.',
      pitfall:
          'Deducting a cost while omitting a taxable reimbursement can distort income.',
      sourceTitle: 'IRS Publication 463 — Independent contractors',
      sourceUrl: pub463Url,
    ),
    TaxGuideEntry(
      title: 'A Form 1099 is not the complete income ledger',
      overview:
          'Report taxable business income even when no information form arrives.',
      details:
          'Reconcile Forms 1099-NEC and 1099-K to gross receipts, refunds, fees and your own sales records.',
      pitfall:
          'A 1099-K can include amounts that are not business revenue, while cash and direct payments may be absent from forms.',
      sourceTitle: 'IRS Publication 334 — Business income',
      sourceUrl: pub334Url,
    ),
    TaxGuideEntry(
      title: 'Owner deductions may not belong on Schedule C',
      overview:
          'Health insurance, owner retirement contributions and QBI are commonly claimed elsewhere.',
      details:
          'Correct placement matters because Schedule C profit affects self-employment tax and other calculations.',
      pitfall:
          'Putting an owner-level deduction on Schedule C can understate self-employment income.',
      sourceTitle: 'IRS Publication 334 — Owner deductions',
      sourceUrl: pub334Url,
    ),
    TaxGuideEntry(
      title: 'Use a separate Schedule C for each business',
      overview:
          'Distinct sole-proprietor businesses generally require separate Schedules C.',
      details:
          'Separate records make it easier to match revenue, expenses, business codes and profit motive to the correct activity.',
      pitfall:
          'Combining unrelated activities can hide losses or apply limitations incorrectly.',
      sourceTitle: 'IRS Schedule C instructions — Line A',
      sourceUrl: scheduleCUrl,
    ),
    TaxGuideEntry(
      title: 'Keep records long enough',
      overview:
          'Records must be kept as long as needed to prove income or deductions.',
      details:
          'The general limitations period is often at least three years, but property, employment-tax, loss, omitted-income and other records can require longer retention.',
      pitfall:
          'Do not delete the only copy after filing. Property-basis records may be needed until after disposition and the later limitations period.',
      sourceTitle: 'IRS — Recordkeeping',
      sourceUrl: recordkeepingUrl,
    ),
    TaxGuideEntry(
      title: 'Federal guidance is not the whole return',
      overview:
          'State, local, entity, industry and international rules can differ.',
      details:
          'This guide is designed for common federal Schedule C issues for U.S. freelancers and sole proprietors.',
      pitfall:
          'Rental, farming, partnerships, S corporations, corporations, employees and specialized industries require different forms and guidance.',
      sourceTitle: 'IRS Publication 334 — Scope',
      sourceUrl: pub334Url,
    ),
  ];
}
