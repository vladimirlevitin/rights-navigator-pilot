-- Reuse the existing official BTL exemption page under the more specific slug used by the 23:31/23:44 playbook migration.
-- Foreign keys reference source_id, so renaming this source slug does not break existing knowledge cards.
update public.sources
set slug = 'btl-income-support-employment-exemption-ulpan',
    checked_on = '2026-09-18'
where slug = 'btl-income-support-employment-exemption-current'
  and url = 'https://www.btl.gov.il/benefits/Income_support/Pages/ptor.aspx'
  and not exists (
    select 1 from public.sources where slug = 'btl-income-support-employment-exemption-ulpan'
  );
