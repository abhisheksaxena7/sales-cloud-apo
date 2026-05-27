public with sharing class CommissionCalculator extends ObservableQueueable {
    private final Id opportunityId;
    public CommissionCalculator(Id opportunityId) {
        this.opportunityId = opportunityId;
    }
    protected override void run(QueueableContext ctx) {
        List<Opportunity> opps = [SELECT Id, Name, Amount, Team_Size__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        if (opps.isEmpty()) {
            System.debug('CommissionCalculator: Opportunity not found for Id: ' + opportunityId);
            return;
        }
        Opportunity opp = opps[0];
        Decimal teamSize = opp.Team_Size__c;
        Decimal amount = opp.Amount;
        // Bug: no null/zero guard. If Team_Size is null or 0, this throws.
        Decimal perPerson = amount / teamSize;
        System.debug('Commission per person for ' + opp.Name + ' = ' + perPerson);
    }
}