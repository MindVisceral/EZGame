## For usage instructions, see the YouTube video below (by Pefeper):
## https://www.youtube.com/watch?v=1i5SB8Ct1y0
class_name TraumaCauser
extends Area3D

## The amount by which all nearby ShakableCamera's trauma is increased
@export_range(0.0, 1.0, 0.05) var trauma_amount: float = 0.1

## Calling this method will check for all shakeable cameras this "trauma causer" overlaps with,
## then increase their camerashake intensity by trauma_amount.
## NOTE: 
func cause_trauma():
	var trauma_areas: Array[Area3D] = get_overlapping_areas()
	for area in trauma_areas:
		if area.has_method("add_trauma"):
			area.add_trauma(trauma_amount)
