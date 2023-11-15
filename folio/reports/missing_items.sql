-- metadb:function missing_items

-- Report pulls a list of missing items, by location if entered, for searching.

DROP FUNCTION IF EXISTS missing_items;

CREATE FUNCTION missing_items ()
RETURNS TABLE (
  item_location text,
  item_barcode text,
  item_call_number text,
  item_enumeration text,
  item_volume text,
  item_title text) 
AS $$
WITH missing_items AS (
  SELECT 
  jsonb_extract_path_text(jsonb,'id')::uuid AS item_id
  FROM folio_inventory.item 
  WHERE jsonb_extract_path_text(jsonb,'status','name')='Missing'
  )
SELECT
  loc."name" AS item_location, 
  it.barcode AS item_barcode,
  hrt.call_number AS item_call_number,
  it.enumeration AS item_enumeration,
  it.volume AS item_volume, 
  fin.title AS item_title
FROM missing_items AS mi
LEFT JOIN folio_inventory.item__t AS it ON mi.item_id = it.id  
LEFT JOIN folio_inventory.location__t AS loc ON it.effective_location_id = loc.id  
LEFT JOIN folio_inventory.holdings_record__t AS hrt ON it.holdings_record_id = hrt.id 
LEFT JOIN folio_inventory.instance__t AS fin ON hrt.instance_id = fin.id
ORDER BY 
  item_location,
  item_call_number
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
