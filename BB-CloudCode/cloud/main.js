// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

Parse.Cloud.beforeDelete("Review", function(request, response) {
        query = new Parse.Query("Restaurant");
        query.get(request.object.get("restaurant").id, {
                success: function(restaurant) {
                    restaurant.remove('reviews', request.object);
                    restaurant.save();
                    response.success();
                },
                    error: function(restaurant, error) {
                        // The object was not retrieved successfully.
                        // error is a Parse.Error with an error code and description.
                        response.error("Error " + error.code + " : " + error.message + " when getting related restaurant for review delete");
                    }
                });

        });

Parse.Cloud.beforeDelete("Awards", function(request, response) {
        query = new Parse.Query("Restaurant");
        query.get(request.object.get("restaurant").id, {
                success: function(restaurant) {
                    restaurant.remove('awards', request.object);
                    restaurant.save();
                    response.success();
                },
                    error: function(restaurant, error) {
                        // The object was not retrieved successfully.
                        // error is a Parse.Error with an error code and description.
                        response.error("Error " + error.code + " : " + error.message + " when getting related restaurant for award delete");
                    }
                });

        });
