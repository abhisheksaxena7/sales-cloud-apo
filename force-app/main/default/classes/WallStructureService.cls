/**
 * @description Service class responsible for creating and managing
 *              WallStructure instances within a house layout.
 *              Follows the Command pattern and enforces governor-limit-safe bulk processing.
 * @author      Copado AI
 */
public with sharing class WallStructureService {

    /**
     * @description Encapsulates all data needed to create a single wall.
     *              Uses @InvocableVariable so it can be passed from Flows.
     */
    public class CreateWallCommand {
        @InvocableVariable(label='Wall ID' required=true)
        public String wallId;

        @InvocableVariable(label='Wall Name' required=true)
        public String name;

        @InvocableVariable(label='Width (metres)' required=true)
        public Decimal widthMetres;

        @InvocableVariable(label='Height (metres)' required=true)
        public Decimal heightMetres;

        @InvocableVariable(label='Thickness (metres)' required=true)
        public Decimal thicknessMetres;

        @InvocableVariable(label='Material (BRICK|CONCRETE|WOOD|DRYWALL|GLASS)')
        public String material;

        @InvocableVariable(label='Orientation (NORTH|SOUTH|EAST|WEST)')
        public String orientation;

        @InvocableVariable(label='House Layout ID' required=true)
        public String houseLayoutId;
    }

    /**
     * @description Holds the outcome of a wall-creation operation.
     */
    public class WallCreationResult {
        public Boolean       isSuccess    { get; private set; }
        public WallStructure wall         { get; private set; }
        public String        errorMessage { get; private set; }

        public WallCreationResult(WallStructure wall) {
            this.isSuccess = true;
            this.wall      = wall;
        }
        public WallCreationResult(String errorMessage) {
            this.isSuccess    = false;
            this.errorMessage = errorMessage;
        }
    }

    /**
     * @description Creates a single WallStructure from a command object.
     * @param  cmd  The CreateWallCommand with all wall properties.
     * @return      A WallCreationResult indicating success or failure.
     */
    public WallCreationResult createWall(CreateWallCommand cmd) {
        if (cmd == null) {
            return new WallCreationResult('Command must not be null');
        }
        try {
            WallStructure.WallMaterial    mat = WallStructure.WallMaterial.valueOf(cmd.material);
            WallStructure.WallOrientation ori = WallStructure.WallOrientation.valueOf(cmd.orientation);
            WallStructure wall = new WallStructure.Builder()
                .setWallId(cmd.wallId)
                .setName(cmd.name)
                .setWidthMetres(cmd.widthMetres)
                .setHeightMetres(cmd.heightMetres)
                .setThicknessMetres(cmd.thicknessMetres)
                .setMaterial(mat)
                .setOrientation(ori)
                .setHouseLayoutId(cmd.houseLayoutId)
                .build();
            return new WallCreationResult(wall);
        } catch (Exception e) {
            return new WallCreationResult(e.getMessage());
        }
    }

    /**
     * @description Bulk-creates multiple WallStructure instances.
     * @param  commands  List of CreateWallCommand objects.
     * @return           List of WallCreationResult in the same order.
     */
    public List<WallCreationResult> createWalls(List<CreateWallCommand> commands) {
        List<WallCreationResult> results = new List<WallCreationResult>();
        if (commands == null || commands.isEmpty()) { return results; }
        for (CreateWallCommand cmd : commands) {
            results.add(createWall(cmd));
        }
        return results;
    }

    /**
     * @description Invocable method callable from Flows.
     * @param  requests  List of CreateWallCommand objects.
     * @return           List of wall names for successfully created walls.
     */
    @InvocableMethod(label='Create Wall Structures' description='Creates one or more wall structures for a house layout')
    public static List<String> createWallsFromFlow(List<CreateWallCommand> requests) {
        WallStructureService svc = new WallStructureService();
        List<String> createdNames = new List<String>();
        for (WallCreationResult res : svc.createWalls(requests)) {
            if (res.isSuccess) {
                createdNames.add(res.wall.name);
            }
        }
        return createdNames;
    }
}