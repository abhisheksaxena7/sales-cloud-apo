/**
 * @description Unit tests for WallStructureService and WallStructure.
 * @author      Copado AI
 */
@IsTest
private with sharing class WallStructureServiceTest {

    private static WallStructureService.CreateWallCommand buildValidCommand() {
        WallStructureService.CreateWallCommand cmd = new WallStructureService.CreateWallCommand();
        cmd.wallId          = 'WALL-001';
        cmd.name            = 'North Boundary Wall';
        cmd.widthMetres     = 5.0;
        cmd.heightMetres    = 3.0;
        cmd.thicknessMetres = 0.3;
        cmd.material        = 'BRICK';
        cmd.orientation     = 'NORTH';
        cmd.houseLayoutId   = 'LAYOUT-001';
        return cmd;
    }

    /** Helper: builds a WallStructure directly via the Builder. */
    private static WallStructure buildWall(Decimal width, Decimal height, Decimal thickness,
                                           WallStructure.WallMaterial mat,
                                           WallStructure.WallOrientation ori) {
        return new WallStructure.Builder()
            .setWallId('W-TEST')
            .setName('Test Wall')
            .setWidthMetres(width)
            .setHeightMetres(height)
            .setThicknessMetres(thickness)
            .setMaterial(mat)
            .setOrientation(ori)
            .setHouseLayoutId('LAYOUT-TEST')
            .build();
    }

    // ── Original tests ────────────────────────────────────────────────────────

    @IsTest
    static void testBuildValidWall() {
        Test.startTest();
        WallStructure wall = new WallStructure.Builder()
            .setWallId('W-001').setName('East Wall')
            .setWidthMetres(4.0).setHeightMetres(2.5).setThicknessMetres(0.2)
            .setMaterial(WallStructure.WallMaterial.CONCRETE)
            .setOrientation(WallStructure.WallOrientation.EAST)
            .setHouseLayoutId('LAYOUT-A').build();
        Test.stopTest();
        System.assertEquals('W-001',     wall.wallId, 'wallId mismatch');
        System.assertEquals('East Wall', wall.name,   'name mismatch');
        System.assertEquals(WallStructure.WallMaterial.CONCRETE, wall.material, 'material mismatch');
    }

    @IsTest
    static void testSurfaceAreaAndVolume() {
        Test.startTest();
        WallStructure wall = new WallStructure.Builder()
            .setWallId('W-002').setName('South Wall')
            .setWidthMetres(6.0).setHeightMetres(3.0).setThicknessMetres(0.5)
            .setMaterial(WallStructure.WallMaterial.WOOD)
            .setOrientation(WallStructure.WallOrientation.SOUTH)
            .setHouseLayoutId('LAYOUT-B').build();
        Test.stopTest();
        System.assertEquals(18.0, wall.getSurfaceArea(), 'Surface area should be 18');
        System.assertEquals(9.0,  wall.getVolume(),      'Volume should be 9');
    }

    @IsTest
    static void testBuilderThrowsOnMissingWallId() {
        Boolean thrown = false;
        Test.startTest();
        try {
            new WallStructure.Builder().setName('Wall').setWidthMetres(1.0)
                .setHeightMetres(1.0).setThicknessMetres(0.1)
                .setMaterial(WallStructure.WallMaterial.DRYWALL)
                .setOrientation(WallStructure.WallOrientation.WEST)
                .setHouseLayoutId('LAYOUT-C').build();
        } catch (IllegalArgumentException e) {
            thrown = true;
        }
        Test.stopTest();
        System.assert(thrown, 'Expected IllegalArgumentException for missing wallId');
    }

    @IsTest
    static void testCreateWallSuccess() {
        WallStructureService svc = new WallStructureService();
        Test.startTest();
        WallStructureService.WallCreationResult r = svc.createWall(buildValidCommand());
        Test.stopTest();
        System.assert(r.isSuccess,                     'Expected success');
        System.assertEquals('WALL-001', r.wall.wallId, 'wallId mismatch');
    }

    @IsTest
    static void testCreateWallNullCommand() {
        WallStructureService svc = new WallStructureService();
        Test.startTest();
        WallStructureService.WallCreationResult r = svc.createWall(null);
        Test.stopTest();
        System.assert(!r.isSuccess, 'Expected failure for null command');
    }

    @IsTest
    static void testCreateWallInvalidData() {
        WallStructureService svc = new WallStructureService();
        WallStructureService.CreateWallCommand cmd = buildValidCommand();
        cmd.widthMetres = 0;
        Test.startTest();
        WallStructureService.WallCreationResult r = svc.createWall(cmd);
        Test.stopTest();
        System.assert(!r.isSuccess, 'Expected failure for zero width');
    }

    @IsTest
    static void testCreateWallsBulk() {
        WallStructureService svc = new WallStructureService();
        List<WallStructureService.CreateWallCommand> cmds = new List<WallStructureService.CreateWallCommand>();
        for (Integer i = 1; i <= 5; i++) {
            WallStructureService.CreateWallCommand cmd = buildValidCommand();
            cmd.wallId = 'WALL-00' + i;
            cmd.name   = 'Wall ' + i;
            cmds.add(cmd);
        }
        Test.startTest();
        List<WallStructureService.WallCreationResult> results = svc.createWalls(cmds);
        Test.stopTest();
        System.assertEquals(5, results.size(), 'Expected 5 results');
        for (WallStructureService.WallCreationResult r : results) {
            System.assert(r.isSuccess, 'All walls should succeed');
        }
    }

    @IsTest
    static void testCreateWallsEmptyList() {
        WallStructureService svc = new WallStructureService();
        Test.startTest();
        List<WallStructureService.WallCreationResult> results = svc.createWalls(
            new List<WallStructureService.CreateWallCommand>()
        );
        Test.stopTest();
        System.assert(results.isEmpty(), 'Expected empty result list');
    }

    @IsTest
    static void testCreateWallsFromFlow() {
        List<WallStructureService.CreateWallCommand> cmds = new List<WallStructureService.CreateWallCommand>();
        cmds.add(buildValidCommand());
        Test.startTest();
        List<String> names = WallStructureService.createWallsFromFlow(cmds);
        Test.stopTest();
        System.assertEquals(1, names.size(),                 'Expected 1 name');
        System.assertEquals('North Boundary Wall', names[0], 'Name mismatch from flow');
    }

    // ── New tests for fixed methods ───────────────────────────────────────────

    @IsTest
    static void testBuildMaterialList() {
        WallStructure wall = buildWall(3.0, 2.5, 0.2, WallStructure.WallMaterial.WOOD, WallStructure.WallOrientation.NORTH);
        Test.startTest();
        String result      = wall.buildMaterialList(new List<String>{ 'Steel', 'Glass', 'Timber' });
        String emptyResult = wall.buildMaterialList(new List<String>());
        String nullResult  = wall.buildMaterialList(null);
        Test.stopTest();
        System.assertEquals('Steel, Glass, Timber, ', result,      'Material list mismatch');
        System.assertEquals('',                       emptyResult, 'Empty list should return empty string');
        System.assertEquals('',                       nullResult,  'Null list should return empty string');
    }

    @IsTest
    static void testIsLoadBearing() {
        Test.startTest();
        // BRICK thick enough and tall enough → load bearing
        WallStructure brickLoadBearing = buildWall(3.0, 3.0, 0.35, WallStructure.WallMaterial.BRICK, WallStructure.WallOrientation.NORTH);
        System.assert(brickLoadBearing.isLoadBearing(), 'Thick tall BRICK wall should be load bearing');

        // BRICK too thin → not load bearing
        WallStructure brickThin = buildWall(3.0, 3.0, 0.2, WallStructure.WallMaterial.BRICK, WallStructure.WallOrientation.NORTH);
        System.assert(!brickThin.isLoadBearing(), 'Thin BRICK wall should NOT be load bearing');

        // BRICK thick but too short → not load bearing
        WallStructure brickShort = buildWall(3.0, 2.0, 0.35, WallStructure.WallMaterial.BRICK, WallStructure.WallOrientation.NORTH);
        System.assert(!brickShort.isLoadBearing(), 'Short BRICK wall should NOT be load bearing');

        // CONCRETE → always load bearing
        WallStructure concrete = buildWall(3.0, 2.5, 0.2, WallStructure.WallMaterial.CONCRETE, WallStructure.WallOrientation.SOUTH);
        System.assert(concrete.isLoadBearing(), 'CONCRETE wall should always be load bearing');

        // WOOD → not load bearing
        WallStructure wood = buildWall(3.0, 2.5, 0.2, WallStructure.WallMaterial.WOOD, WallStructure.WallOrientation.EAST);
        System.assert(!wood.isLoadBearing(), 'WOOD wall should NOT be load bearing');
        Test.stopTest();
    }

    @IsTest
    static void testClassifyHeight() {
        Test.startTest();
        WallStructure highWall     = buildWall(3.0, 4.0, 0.2, WallStructure.WallMaterial.GLASS, WallStructure.WallOrientation.WEST);
        WallStructure standardWall = buildWall(3.0, 3.0, 0.2, WallStructure.WallMaterial.GLASS, WallStructure.WallOrientation.WEST);
        WallStructure lowWall      = buildWall(3.0, 2.0, 0.2, WallStructure.WallMaterial.GLASS, WallStructure.WallOrientation.WEST);
        Test.stopTest();
        System.assertEquals('High',     highWall.classifyHeight(),     'Expected High');
        System.assertEquals('Standard', standardWall.classifyHeight(), 'Expected Standard');
        System.assertEquals('Low',      lowWall.classifyHeight(),      'Expected Low');
    }

    @IsTest
    static void testSafeDivide() {
        WallStructure wall = buildWall(3.0, 2.5, 0.2, WallStructure.WallMaterial.DRYWALL, WallStructure.WallOrientation.NORTH);
        Test.startTest();
        Decimal result    = wall.safeDivide(10, 2);
        Decimal divByNull = wall.safeDivide(10, null);
        Test.stopTest();
        System.assertEquals(5, result,    'Expected 10/2 = 5');
        System.assertEquals(0, divByNull, 'Expected 0 when dividing by null');
    }

    @IsTest
    static void testUpdateRelatedRecords() {
        WallStructure wall = buildWall(3.0, 2.5, 0.2, WallStructure.WallMaterial.DRYWALL, WallStructure.WallOrientation.NORTH);
        Test.startTest();
        wall.updateRelatedRecords(new List<String>());
        wall.updateRelatedRecords(new List<String>{ 'LAYOUT-001', 'LAYOUT-002' });
        Test.stopTest();
        System.assert(true, 'updateRelatedRecords completed without errors');
    }

    @IsTest
    static void testLogWallInfo() {
        WallStructure wall = buildWall(3.0, 2.5, 0.2, WallStructure.WallMaterial.BRICK, WallStructure.WallOrientation.NORTH);
        Test.startTest();
        wall.logWallInfo();
        Test.stopTest();
        System.assert(true, 'logWallInfo completed without errors');
    }
}