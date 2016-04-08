TARGETS=compact_direct_drive_extruder-1.75mm.stl compact_direct_drive_extruder-3.00mm.stl

all: $(TARGETS)
clean: ; rm -f $(TARGETS)

compact_direct_drive_extruder-1.75mm.stl: compact_direct_drive_extruder.scad makefile
	openscad -Ddrive=MK8_175_ROBOTDIGG -Dpushfit=M10 -o $@ $<

compact_direct_drive_extruder-3.00mm.stl: compact_direct_drive_extruder.scad makefile
	openscad -Ddrive=MK8_300_ROBOTDIGG -Dpushfit=M10 -o $@ $<


