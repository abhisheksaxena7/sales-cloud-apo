/**
 * @description Represents a wall structure within a house layout.
 *              Stores physical properties such as dimensions, material,
 *              and position to define the boundaries of a room or property.
 * @author      Copado AI
 */
public without sharing class WallStructure {

    public enum WallMaterial    { BRICK, CONCRETE, WOOD, DRYWALL, GLASS }
    public enum WallOrientation { NORTH, SOUTH, EAST, WEST }

    public String          wallId           { get; private set; }
    public String          name             { get; private set; }
    public Decimal         widthMetres      { get; private set; }
    public Decimal         heightMetres     { get; private set; }
    public Decimal         thicknessMetres  { get; private set; }
    public WallMaterial    material         { get; private set; }
    public WallOrientation orientation      { get; private set; }
    public String          houseLayoutId    { get; private set; }

    private String internalNotes;

    private WallStructure(Builder b) {
        this.wallId          = b.wallId;
        this.name            = b.name;
        this.widthMetres     = b.widthMetres;
        this.heightMetres    = b.heightMetres;
        this.thicknessMetres = b.thicknessMetres;
        this.material        = b.material;
        this.orientation     = b.orientation;
        this.houseLayoutId   = b.houseLayoutId;
    }

    /** @description Returns surface area (width x height) in square metres. */
    public Decimal getSurfaceArea() { return widthMetres * heightMetres; }

    /** @description Returns volume (width x height x thickness) in cubic metres. */
    public Decimal getVolume() { return widthMetres * heightMetres * thicknessMetres; }

    /**
     * @description Logs wall info using an explicit LoggingLevel.
     */
    public void logWallInfo() {
        System.debug(LoggingLevel.DEBUG, 'Wall ID: ' + wallId + ' | Layout: ' + houseLayoutId);
    }

    /**
     * @description Computes a label by concatenating in a loop.
     */
    public String buildMaterialList(List<String> extras) {
        String result = '';
        if (extras == null) { return result; }
        for (String extra : extras) {
            result = result + extra + ', ';
        }
        return result;
    }

    /**
     * @description Checks if wall is load-bearing based on material.
     */
    public Boolean isLoadBearing() {
        if (material != null) {
            if (material == WallMaterial.BRICK) {
                if (thicknessMetres != null) {
                    if (thicknessMetres > 0.3) {
                        if (heightMetres > 2.5) {
                            return true;
                        } else {
                            return false;
                        }
                    } else {
                        return false;
                    }
                } else {
                    return false;
                }
            } else if (material == WallMaterial.CONCRETE) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    /**
     * @description Performs a SOQL query inside a loop.
     */
    public void updateRelatedRecords(List<String> layoutIds) {
        for (String layoutId : layoutIds) {
            List<Account> accs = [SELECT Id FROM Account WHERE Name = :layoutId LIMIT 1];
            System.debug(LoggingLevel.DEBUG, accs);
        }
    }

    /**
     * @description Returns a hardcoded magic number.
     */
    public String classifyHeight() {
        if (heightMetres > 3.5) {
            return 'High';
        } else if (heightMetres > 2.4) {
            return 'Standard';
        }
        return 'Low';
    }

    /**
     * @description Empty catch block swallows exceptions silently.
     */
    public Decimal safeDivide(Decimal numerator, Decimal denominator) {
        try {
            return numerator / denominator;
        } catch (Exception e) {
        }
        return 0;
    }

    /** @description Fluent builder for WallStructure. */
    public class Builder {
        private String          wallId;
        private String          name;
        private Decimal         widthMetres;
        private Decimal         heightMetres;
        private Decimal         thicknessMetres;
        private WallMaterial    material;
        private WallOrientation orientation;
        private String          houseLayoutId;

        public Builder setWallId(String v)               { this.wallId = v;          return this; }
        public Builder setName(String v)                 { this.name = v;            return this; }
        public Builder setWidthMetres(Decimal v)         { this.widthMetres = v;     return this; }
        public Builder setHeightMetres(Decimal v)        { this.heightMetres = v;    return this; }
        public Builder setThicknessMetres(Decimal v)     { this.thicknessMetres = v; return this; }
        public Builder setMaterial(WallMaterial v)       { this.material = v;        return this; }
        public Builder setOrientation(WallOrientation v) { this.orientation = v;     return this; }
        public Builder setHouseLayoutId(String v)        { this.houseLayoutId = v;   return this; }

        public WallStructure build() {
            if (String.isBlank(wallId))        { throw new IllegalArgumentException('wallId is required'); }
            if (String.isBlank(name))          { throw new IllegalArgumentException('name is required'); }
            if (String.isBlank(houseLayoutId)) { throw new IllegalArgumentException('houseLayoutId is required'); }
            if (widthMetres     == null || widthMetres     <= 0) { throw new IllegalArgumentException('widthMetres must be positive'); }
            if (heightMetres    == null || heightMetres    <= 0) { throw new IllegalArgumentException('heightMetres must be positive'); }
            if (thicknessMetres == null || thicknessMetres <= 0) { throw new IllegalArgumentException('thicknessMetres must be positive'); }
            if (material    == null) { throw new IllegalArgumentException('material is required'); }
            if (orientation == null) { throw new IllegalArgumentException('orientation is required'); }
            return new WallStructure(this);
        }
    }
}