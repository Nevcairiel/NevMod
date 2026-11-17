-- add the movement speed to the character stat sheet
if not PAPERDOLL_STATCATEGORIES then return end
table.insert(PAPERDOLL_STATCATEGORIES[1].stats, { stat = "MOVESPEED"})
