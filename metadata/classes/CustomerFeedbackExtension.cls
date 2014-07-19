public class CustomerFeedbackExtension {
    public boolean error {get; set;}
    public string competitor {get; set;}
    public string competitorName {get; set;}
    public string product {get; set;}
    public double price {get; set;}
    public string otherProduct {get; set;}
    public string features {get; set;}
    public string pros {get; set;}
    public string cons {get; set;}
    public boolean showName {get; set;}
    public boolean showPrdName {get; set;}
    public map<Id, Competitor_Product__c> mapCP = new map<Id, Competitor_Product__c>();

    public Customer_Feedback__c cf;
    public string retURL {get; set;}

    public list<SelectOption> getCompetitorOptions() {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '--None--'));

        for (Competitor__c co:[SELECT Id, Name FROM Competitor__c]) {
            options.add(new SelectOption(co.Id, co.Name));
        }

        options.add(new SelectOption('Other', 'Other'));

        return options;
    }

    public list<SelectOption> getProductOptions() {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '--None--'));

        for (Competitor_Product__c cp:mapCP.values()) {
            options.add(new SelectOption(cp.Id, cp.Name));
        }

        options.add(new SelectOption('Other', 'Other'));

        return options;
    }


    public CustomerFeedbackExtension(ApexPages.StandardController controller) {
        cf = (Customer_Feedback__c) controller.getRecord();

        retURL = ApexPages.currentPage().getParameters().get('retURL');

        showName = false;
        showPrdName = false;
    }

    public PageReference showProduct() {
        if (competitor == 'Other') {
            showName = true;
            mapCP = new map<Id, Competitor_Product__c>();
            price = null;
        }
        else {
            showName = false;
            competitorName = null;

            mapCP = new map<Id, Competitor_Product__c>([SELECT Id, Name, Competitor__c, Price__c, Features__c, Pros__c, Cons__c FROM Competitor_Product__c WHERE Competitor__c = :competitor]);
            price = null;
        }

//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, competitor));
        return null;
    }

    public PageReference showProductName() {
        if (product == 'Other') {
            showPrdName = true;
            price = null;
        }
        else {
            showPrdName = false;
            otherProduct = null;
            if (mapCP.containsKey(product)) {
                price = Double.valueOf(mapCP.get(product).Price__c);
                features = mapCP.get(product).Features__c;
                pros = mapCP.get(product).Pros__c;
                cons = mapCP.get(product).Cons__c;
            }
            else {
                price = null;
                features = null;
                pros = null;
                cons = null;
            }
        }

//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, product + ' -- ' + price));
        return null;
    }

    public PageReference save() {
        error = true;
        if (competitor == null || competitor == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please select Competitor'));
            return null;
        }

        if (competitor == 'Other' && (competitorName == null ||competitorName == '')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please enter Competitor Name'));
            return null;
        }

        if (product == null || product == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please select Product'));
            return null;
        }

        if (product == 'Other' && (otherProduct == null || otherProduct == '')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please enter Product Name'));
            return null;
        }

        //create temp entry for Product and Competitor and take feedback.
        if (competitor == 'Other') {
            Competitor__c comp = new Competitor__c(Name = competitorName);
            insert comp;

            Competitor_Product__c compProd = new Competitor_Product__c(Name = otherProduct, Competitor__c = comp.Id, Price__c = price, Features__c = features, Pros__c = pros, Cons__c = cons);
            insert compProd;

            cf.Competitor_Product__c = compProd.Id;
        }
        else
            cf.Competitor_Product__c = product;

        try {
            upsert cf;
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
            return null;
        }

        error = false;

        PageReference pr = new PageReference(retURL);
        return pr;
    }

    public PageReference cancel() {
        PageReference pr = new PageReference(retURL);
        return pr;
    }
}