/**
 * @description       : Gestor principal para integracion con Reddit
 * @author            : erika.gaby0922@gmail.com
 * @group             : Interno
 * @last modified on  : 06-12-2023
 * @last modified by  : erika.gaby0922@gmail.com
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   06-12-2023   erika.gaby0922@gmail.com   Initial Version
**/
public with sharing class managerReddit {
    public managerReddit() {
    }

    /**
    * Obtiene los datos del objeto Reddit Items
    * @return list_variable
    */
    @AuraEnabled(cacheable=true)
    public static List<reddit_items__c> getRedditItems() {
        List<reddit_items__c> list_variable = [SELECT Id, author_fullname__c, Title__c, thumbnail__c, selftext__c, CreatedDate
                                                FROM reddit_items__c];
        return list_variable;
    }

    /**
    * Obtiene datos de Json Reddit y los inserta en el objeto Reddit Items
    * @return list_RedditItems
    */
    public static List<reddit_items__c> insertaItemsDeRestService() {
        // String urlGet = 'https://www.reddit.com/r/subreddit/new.json?sort=new';
        String urlGet = 'https://www.reddit.com/r/askscience/top/.json?sort=top';
        String metodo = 'GET';

        HTTPResponse http_RedditItems = getRespuestaHTTP(urlGet, metodo);
            System.debug(logginglevel.DEBUG, '@managerReddit [insertaItemsDeRestService] http_RedditItems: '+http_RedditItems.getBody()) ;

        List<Object> list_Childrens = convierteResponseEnLista(http_RedditItems);
        List<reddit_items__c> list_RedditItems = convierteListaEnObjReddit(list_Childrens);
        insert list_RedditItems;
            System.debug(logginglevel.DEBUG, '@managerReddit [insertaItemsDeRestService] list_RedditItems: '+list_RedditItems) ;

        return list_RedditItems;
    }

    /**
        * Metodo para obtener los datos de un servidor externo
        * @return HTTPResponse res
    */
    private static HTTPResponse getRespuestaHTTP(String urlGet, String metodo) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(urlGet);
        req.setMethod(metodo);

        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }

    /**
        * Obtiene los Items de cada children
        * @return Map<String, Object> map_ItemsReddit
    */
    private static List<Object> convierteResponseEnLista(HTTPResponse http_RedditItems) {
        List<Object> list_Childrens = new List<Object>();

        Map<String, Object> map_Principal = (Map<String, Object>) JSON.deserializeUntyped(http_RedditItems.getBody());
            System.debug(logginglevel.DEBUG, '@managerReddit [convierteResponseEnLista] map_Principal: '+map_Principal) ;
            System.debug(logginglevel.DEBUG, '@managerReddit [convierteResponseEnLista] map_Principal: '+map_Principal.get('data')) ;

        Map<String, Object> map_Secundario = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(map_Principal.get('data')));
            System.debug(logginglevel.DEBUG, '@managerReddit [convierteResponseEnLista] map_Secundario: '+map_Secundario) ;
            System.debug(logginglevel.DEBUG, '@managerReddit [convierteResponseEnLista] map_Secundario children: '+map_Secundario.get('children')) ;

        Object obj_Children = JSON.deserializeUntyped(JSON.serialize(map_Secundario.get('children')));
            System.debug(logginglevel.DEBUG, '@managerReddit [convierteResponseEnLista] obj_Children: '+obj_Children) ;

        list_Childrens = (List<Object>) obj_Children;
            System.debug(logginglevel.DEBUG, '@managerReddit [convierteResponseEnLista] list_Childrens: '+list_Childrens) ;
        return list_Childrens;
    }

    /**
    * detalle
    * @return list_variable
    */
    private static List<reddit_items__c> convierteListaEnObjReddit(List<Object> list_Childrens) {
        List<reddit_items__c> list_variable = new List<reddit_items__c>() ;

        for(Object children : list_Childrens){
            Map<String, Object> map_DataChildren = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(children));
                System.debug(logginglevel.DEBUG, '@managerReddit [convierteResponseEnLista] map_DataChildren: '+map_DataChildren.get('data')) ;

            Map<String, Object> map_ItemsReddit = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(map_DataChildren.get('data')));
                System.debug(logginglevel.DEBUG, '@managerReddit [convierteResponseEnLista] map_ItemsReddit title: '+map_ItemsReddit.get('title')) ;

            reddit_items__c obj_RedditItem = generaRegistroRedditItem(map_ItemsReddit);
            list_variable.add(obj_RedditItem);
        }

        return list_variable;
    }

    /**
    * Mapea cada valor con el campo que corresponde
    * @return obj_RedditItem
    */
    private static reddit_items__c generaRegistroRedditItem(Map<String, Object> map_ItemsReddit) {
        reddit_items__c obj_RedditItem = new reddit_items__c();
            obj_RedditItem.author_fullname__c = map_ItemsReddit.get('author_fullname').toString();
            obj_RedditItem.Title__c           = map_ItemsReddit.get('title').toString();
            obj_RedditItem.thumbnail__c       = map_ItemsReddit.get('thumbnail').toString();
            obj_RedditItem.selftext__c        = map_ItemsReddit.get('selftext').toString();
        return obj_RedditItem;
    }
}