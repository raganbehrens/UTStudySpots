#!/usr/bin/env
var express = require('express');
var app = express();
var MongoClient = require("mongodb").MongoClient
var crypto = require("crypto")
app.use(express.static(__dirname+ "/../"));
var url = 'mongodb://localhost:27017/mydb';
var countScores = 1;
//var database;
function createcollection(){
	console.log("inside database");
	MongoClient.connect(url, function ( err, db ) {
		console.log("access database");
		db.createCollection("users");
		var collection = db.collection("users");
		collection.insert({id : 1, username: "Ragan", password : "password"});
		db.createCollection("UTPlaces");
		db.createCollection("RequestForms");
		db.close();
	});
}
function updateAll(){
  MongoClient.connect(url, function (err, db){
    db.collection('Floors').updateMany({}, {$set: {comments:[]}});
    db.close();
  });
}

function createPlaces(){
	MongoClient.connect(url, function ( err, db){
		console.log("access database");
		var collection = db.collection("UTPlaces");
		// var locations = ["Student Activity Center (SAC)",

  //                "Flawn Academic Center (FAC)", "Perry-Castaneda Library (PCL)",

  //                "Union Building (UNB)","Gates Dell Complex (GDC)",

  //                "Robert Lee Moore Hall (RLM)", "Liberal Arts Building (CLA)",

  //                "Robert A. Welch Hall (WEL)", "Norman Hackerman Building (NHB)",

  //                "Student Services Building (SSB)"
		collection.insert({_id : 1, placeName:"Student Activity Center", acro: "SAC", averageNoise: 0.00, averageOccupation: 0.00, count: 0, floors: 3});
		collection.insert({_id : 2, placeName:"Flawn Academic Center", acro: "FAC", averageNoise: 0.00, averageOccupation: 0.00, count: 0, floors: 6});
		collection.insert({_id : 3, placeName:"Perry-Castaneda Library", acro: "PCL", averageNoise: 0.00, averageOccupation: 0.00, count: 0, floors: 6});
		collection.insert({_id : 4, placeName:"Union Building", acro: "UNB", averageNoise: 0.00, averageOccupation: 0.00, count: 0, floors: 5});
		collection.insert({_id : 5, placeName:"Gates Dell Complex", acro: "GDC", averageNoise: 0.00, averageOccupation: 0.00, count: 0, floors: 7});
		collection.insert({_id : 6, placeName:"Robert Lee Moore Hall", acro: "RLM", averageNoise: 0.00, averageOccupation: 0, count: 0, floors: 10});
		collection.insert({_id : 7, placeName:"Liberal Arts Building", acro: "CLA", averageNoise: 0.00, averageOccupation: 0.00, count: 0, floors: 5});
		collection.insert({_id : 8, placeName:"Robert A. Welch Hall", acro: "WEL", averageNoise: 0.00, averageOccupation: 0.00, count: 0, floors: 7});
		collection.insert({_id : 9, placeName:"Norman Hackerman Building", acro: "NHB", averageNoise: 0.00, averageOccupation: 0.00, count: 0, floors: 9});
		collection.insert({_id : 10, placeName:"Student Services Building", acro: "SSB", averageNoise: 0.00, averageOccupation: 0.00, count: 0, floors: 6});
		db.close();
	
	});
}
function createFloors(){
	MongoClient.connect(url, function (err, db){
		console.log("access database");
		//db.createCollection("Floors");
		var collection = db.collection("Floors");
		var utplaces = db.collection("UTPlaces");
		utplaces.find().toArray(function (err, results){
			if(err){
				console.log("error has occurred");
			}
			else if(results.length){
				var count = 1;
				console.log("inserting collections..")
				 for(var i =0; i< results.length; i++){
				 	console.log(results[i].floors);
				 	for(var j =1; j<=results[i].floors; j++){
				 		// fix this
				 		collection.insert({_id : count, placeName: results[i].placeName, floorLevel: j , averageNoise: 0.00, averageOccupation: 0.00 , count: 0, comments:[]});
				 		count++;
				 	}
				 }
				 console.log("Done inserting database");
			}
			db.close();
		});
		

	});
}
function getusers(callback){
	MongoClient.connect(url, function(err, db){
		var users = db.collection("users");
		users.find({id: 1}).toArray(function (err, result) {
			if (err) {
				console.log(err);
				callback(err, null);
			}
			else if (result.length) {
				console.log(result[0].username);
				callback(null, result);
			}
			else {
				console.log("nothing found");
				callback(null, null);
			}
			db.close();
		});
	});
}

function getPlaces(callback){
	MongoClient.connect(url, function (err, db){
		var places = db.collection("UTPlaces");
		places.find().toArray(function (err, results){
			if(err){
				console.log(err);
				callback(err, null);
			} else if(results.length){
				callback(null, results);
			} 
		});
	});
}
var updateFloor = function(db, id, noiseRating, occupationRating, count , message, user, callback) {
   console.log("AVERAGE NOISE IS" + noiseRating);
   console.log("message is" + message);
   	var date = new Date();
	date.setHours(date.getHours()-6);
	var myDate = (date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear() + " at ";

	var period = " am"
	var hours = date.getHours()
	if (hours>=12){
		if (hours >12) {
			hours = hours%12;
		}
		period = " pm"

	}
	if(hours == 0){
		hours = 12
	}
	var min= date.getMinutes()
	if(min <10)
		myDate = myDate +hours +":"+ "0" +min + period
	else
		myDate = myDate +hours +":"+ min + period
   db.collection('Floors').updateOne(

      { '_id' : id }, 
      
        {$set: { averageNoise: noiseRating,
         averageOccupation:  occupationRating, count: count},
        $currentDate: { "lastModified": true }, 
        $push :{ 
        	comments:{
        		$each:[{"user": user, "message": message, "date": myDate, "timeStamp": Date.now()}], 
        		$sort: {"timeStamp":-1},
        		$slice: 10
        	}
        }
      }, function(err, results) {
      console.log(results);
      callback();
   });
};
var updateFloor2 = function (db, id, noiseRating, occupationRating, count, callback) {
	db.collection('Floors').updateOne(

      { '_id' : id }, 
      
        {$set: { averageNoise: noiseRating,
         averageOccupation:  occupationRating, count: count},
        $currentDate: { "lastModified": true }
      }, function(err, results) {
      console.log(results);
      callback();
   });
};

function updateInfo(id, noiseRating, occupationRating, message, user, callback){

  MongoClient.connect(url, function ( err, db){
    getFloorAvg(id, db, function(err, result){
      // console.log((result.averageNoise*result.count + noiseRating)/(result.count+1));
      // var avgNoiseRating = (result.averageNoise*result.count + noiseRating)/(result.count+1);
      // var avgOccupationRating = (result.averageOccupation*result.count + occupationRating)/(result.count+1);

	      if(message.length){
	      	addScores(id, noiseRating, occupationRating, function (result2){
	      		console.log(result2)
	      		console.log("AFTER insert")
	      		updateFloor(db, id, result2.avgNoise, result2.avgOccupation, result2.count, message, user, function(){
		        db.close();
		        updatePlaces(result.placeName, function(){
		        	callback();
		        	var timeout = setTimeout(function(){
	        			deleteDate();
	        		}, 7200005)
		        });
		        
		      });
	      	});
		      
  		  } else {
  		  	addScores(id, noiseRating, occupationRating, function (result2){
  		  		console.log(result2)
  		  		console.log("AFTER insert")
  		  		updateFloor2(db, id, result2.avgNoise, result2.avgOccupation, result2.count, function(){
	        	db.close();
	        	updatePlaces(result.placeName, function(){
	        		callback();
	        		var timeout = setTimeout(function(){
	        			deleteDate();
	        		}, 7200005)
	        	});
	        
	      		});
	      	});
  		  }
      
      //console.log("UPDATED" + result);
      
    });
    
  });
}

function getFloorAvg(id, db, callback){
		var places = db.collection("Floors");
		places.find({_id: id}).toArray(function (err, results){
			if(err){
				console.log(err);
				callback(err, null);
			} else if(results.length){

				callback(null, results[0]);
			} 
		});
}

function getPlace(id , callback){
	MongoClient.connect(url, function (err, db){
		var places = db.collection("UTPlaces");

		places.find({"_id": id}).toArray(function (err, results){
			if(err){
				console.log(err);
				callback(err, null);
			} else if(results.length){
				callback(null, results[0]);
			} else {
				console.log("nothing found");
			}
		});
		db.close()
	});
}
function getFloor(place , floor , callback){
	MongoClient.connect(url, function (err, db){
		var places = db.collection("Floors");
		console.log(place);
		places.find({placeName: place ,floorLevel: floor}).toArray(function (err, results){
			if(err){
				console.log(err);
				callback(err, null);
			} else if(results.length){
				callback(null, results[0]);
			} else {
				("nothing found for floor level")
			}
		});
	});
}


var updatePlace = function(db, place, noiseRating, occupationRating, count, callback) {
   db.collection('UTPlaces').updateOne(
      { 'placeName' : place }, 
      {
        $set: { averageNoise: noiseRating,
         averageOccupation:  occupationRating, 'count': count},
         
        $currentDate: { "lastModified": true }
      }, function(err, results) {
      console.log(results);
      callback();
   });
};

var getAvgPlaces = function(db, place, callback) {
  var collection = db.collection( 'Floors' );
  collection.aggregate( 
      [ { '$match': { "placeName": place } },
        { '$group': { '_id': "$placeName" , 'avgNoise': { '$sum': {'$multiply': [ "$averageNoise", "$count" ]} }, 
        'avgOccupation':{'$sum' : {'$multiply' :["$averageOccupation", "$count" ]} } , 'count' :{ '$sum' : '$count' } } } 		
      ],	  
	  function(err, results) {
        //assert.equal(err, null);
        if(err){
        	console.log(err);
        } else if(results.length){
	        console.log(results);
	        callback(results[0]);
        }else {
        	console.log("no data found");
        }
      }
  );
}

function updatePlaces(placeName, callback){
	MongoClient.connect(url, function (err, db){
		getAvgPlaces(db, placeName, function(result){
			if(result.count != 0){
				updatePlace(db, result._id, result.avgNoise/result.count, result.avgOccupation/result.count, result.count, 
					function() {db.close();
					callback();});
				
			} else {
				updatePlace(db, result._id, result.avgNoise, result.avgOccupation, result.count, 
					function() {
						db.close();
					callback();});
			}
			
		});
	});
}

function register(username, password, firstname , lastname , callback){
	MongoClient.connect(url, function (err, database){

		var collection = database.collection('login')
		collection.find({'user' : username}).toArray(function(error, results){
		if (results.length > 0){
			console.log("User already exists")
			console.log(results)
			callback({success: "NO"});
		}
		else{
			var hashed = crypto.createHash('sha512').update(password).digest("hex");
			collection.insert({'user' : username, 'password' : hashed, 'firstname': firstname, 'lastname' : lastname, 'favorites':[]}, function(err){
				console.log("Inserted username: " + username + "password: " + hashed)
				console.log(err)
				callback({success: "YES"});
			})
		}
		database.close();

		})
	})
}

function login(username, password, callback){
	MongoClient.connect(url, function (err, database){
		var collection = database.collection('login')
		var hashed = crypto.createHash('sha512').update(password).digest("hex");
		collection.find({'user' : username, 'password' : hashed}).toArray(function(error, results){
			if (results.length == 0){
				console.log("User does not exist")
				callback({success: "NO"});
			} else{
				callback({success: "YES", "firstname" : results[0].firstname, "lastname" : results[0].lastname});
			}
			console.log(results)
		});
	database.close();
	})
}

function getFavorites(username, callback){
	MongoClient.connect(url, function (err, database){
		var collection = database.collection('login')
		collection.find({'user' : username}).toArray( function(err, results){
			if(results.length){
				callback(results[0]);
			} else {
				console.log("nothing found")
			}
		})
	database.close();
	})	
}

function addFavorite(username, id, callback){
	MongoClient.connect(url, function (err, database){
		var collection = database.collection('login')
		collection.update({'user' : username}, {$addToSet: {'favorites' : id}}, function(err, results){
			console.log("updated favorites")
			callback({success: "YES"})
		})
	database.close();
	})
}

function unfavorite(username, id, callback){
	MongoClient.connect(url, function (err, database){
		var collection = database.collection('login')
		collection.update({'user' : username}, {$pull: {'favorites' : id}}, function(err, results){
			console.log("removed favorites")
			callback({success: "YES"})
		})
	database.close();
	})
}
function sortbyNoise(callback) {
	MongoClient.connect(url, function (err, db){
		var places = db.collection("UTPlaces");

		places.find({}).sort({"averageNoise" : 1}).toArray(function (err, results){
			if(err){
				console.log(err);
				callback(err, null);
			} else if(results.length){
				callback(null, results);
			} else {
				callback(null , []);
				console.log("nothing found");
			}
		});
		db.close()
	});
}
function sortbyOccupation(callback) {
	MongoClient.connect(url, function (err, db){
		var places = db.collection("UTPlaces");

		places.find({}).sort({"averageOccupation" : 1}).toArray(function (err, results){
			if(err){
				console.log(err);
				callback(err, null);
			} else if(results.length){
				callback(null, results);
			} else {
				callback(null , []);
				console.log("nothing found");
			}
		});
		db.close()
	});
}
function sortbyBoth(callback) {
	MongoClient.connect(url, function (err, db){
		var places = db.collection("UTPlaces");

		places.find({}).sort({"averageNoise" : 1, "averageOccupation":1}).toArray(function (err, results){
			if(err){
				console.log(err);
				callback(err, null);
			} else if(results.length){
				callback(null, results);
			} else {
				callback(null , []);
				console.log("nothing found");
			}
		});
		db.close()
	});
}
function addScores(id, noiseRating, occupationRating, callback){
	MongoClient.connect(url, function (err, db) {
		var ratings = db.collection("Ratings");
		ratings.insert({floorId: id, noiseRating: noiseRating, occupationRating: occupationRating, uniqueId: countScores, dateAdded: new Date()}, function (err, doc){
			console.log("inserted Succesfully");
			countScores++;

			calculateAvg(id, db ,function (result){
				console.log("RESULTS are");
				console.log(result);
				callback(result);
				db.close();
			});
		});
		
		
	});

}
function calculateAvg(id, db, callback){
	var collection = db.collection( 'Ratings' );
  collection.aggregate( 
      [ { '$match': { "floorId": id } },
        { '$group': 
        { '_id': "$floorId" , 'avgNoise': { '$avg': '$noiseRating'}, 
        'avgOccupation':{'$avg' : '$occupationRating'  } , 'count' :{ '$sum' : 1 } } } 		
      ],	  
	  function(err, results) {
        //assert.equal(err, null);
        if(err){
        	console.log("it has an error");
        	console.log(err);
        } else if(results.length){
        	console.log("it has a length");
	        console.log(results);
	        callback(results[0]);
        }else {
        	callback({'avgNoise': 0.0 , 'avgOccupation':0.0, 'count': 0})
        	console.log("no data found");
        }
      }
  );
}
function calculateAvgAll(db, callback){
	var collection = db.collection( 'Ratings' );
  collection.aggregate( 
      [
        { '$group': 
        { '_id': "$floorId" , 'avgNoise': { '$avg': '$noiseRating'}, 
        'avgOccupation':{'$avg' : '$occupationRating'  } , 'count' :{ '$sum' : 1 } } } 		
      ],	  
	  function(err, results) {
        //assert.equal(err, null);
        if(err){
        	console.log("it has an error");
        	console.log(err);
        } else if(results.length){
        	console.log("it has a length");
	        console.log(results);
	        callback(results);
        }else {
        	console.log("no data found");
        }
      }
  );
}
function deleteDate(){
	MongoClient.connect(url, function (err, db) {
		var collection = db.collection("Ratings")
		var twohoursago = new Date()
//		console.log(twohoursago.getMinutes())
//		twohoursago.setMinutes(twohoursago.getMinutes() - 5);
//		console.log(twohoursago.getMinutes())
		twohoursago.setHours(twohoursago.getHours() - 2);
		collection.findOneAndDelete( { dateAdded : {"$lt" : twohoursago} }, function (err, doc){
			console.log(doc)
			if(doc.value){
				console.log("Inside doc");
				console.log(doc.value.floorId);
				calculateAvg(doc.value.floorId, db, function(results){
					console.log(results)
					updateFloor2(db,doc.value.floorId, results.avgNoise, results.avgOccupation, results.count, function(){

						db.collection("Floors").find({_id: doc.value.floorId}).toArray(function (err, results2){
							if(err){
								console.log(err);
							} else if(results2.length){
								console.log("before updatePlaces")
								updatePlaces(results2[0].placeName, function(){})
							} else {
		
								console.log("nothing found");
							}
							db.close()
						})
					});


				});
			} else {
				console.log("Empty")
			}	
		});


	});
	
}
function addLocation(name, address, description, callback){
	MongoClient.connect(url, function ( err, db){
		console.log("access database");
		var collection = db.collection("NewLocations");
		collection.insert({"placeName":name, "address": address, "description": description});
		db.close();
		callback();
	
	});
}
//createcollection();
//createPlaces();
//createFloors();
//updateAll();
//deleteDate();

//--------------
// ROUTES
//--------------

app.get("/", function (req, res){
	res.send("hi");
});
app.get("/users", function (req, res){
	getusers(function(err, result){
		res.json(result);
	});
});

app.get('/register', function (req, res){

	var params = req.params
	var email = req.query.email
	var password = req.query.password
	var firstname = req.query.firstname
	var lastname = req.query.lastname
	var response = register(email, password, firstname, lastname, function (response){
		//console.log("response is")
		//console.log(response)
		res.json(response)
	})
});

app.get('/login', function(req, res){

	var params = req.params;
	var email = req.query.email
	var password = req.query.password
	var response = login(email, password, function (response){
		res.json(response)
	})
});
app.get("/places",function (req , res){
	getPlaces(function(err, results){
		res.json(results);
	});
});
app.get("/place", function (req, res){
	var strid = req.query.id
	

	var id = parseInt(strid);
	console.log(id);
	getPlace( id, function (err, result){
		
		console.log(result);
		res.json(result);
	});

});
app.get("/sort", function (req, res){
	var str = req.query.sortby
	if(str == "Noise"){
		sortbyNoise(function (err, result){
		
		console.log(result);
		res.json({"locations":result});
		});
	} else if (str == "Occupancy") {
		sortbyOccupation(function (err, result){
		
		console.log(result);
		res.json({"locations":result});
		});
	} else {
		sortbyBoth(function (err, result){
		
		console.log(result);
		res.json({"locations" : result});
		});
	}
	

});

app.get("/floor", function (req, res){
	var place =req.query.locationName;
	var floorLevel = parseInt(req.query.floorLevel);
	console.log(floorLevel);
	getFloor(place, floorLevel, function (err, result){
		console.log(result);
		res.json(result);
	});
});

app.get("/updateFloor", function (req, res){
  var occupancyRate = parseInt(req.query.occupancyRate)
  var noiseRate = parseInt(req.query.noiseRate)
  var id = parseInt(req.query.id)
  var username = req.query.user
  var message = req.query.comment
  console.log(message)
  console.log(occupancyRate)
  console.log(noiseRate)
  updateInfo(id, noiseRate, occupancyRate, message, username, function(){
  	res.json({"success": "YES"});
  });
  
});
app.get("/request", function (req, res){
	res.send("hi")
});

app.get("/addFavorite", function (req, res){
	var username = req.query.username
	var id = parseInt(req.query.id)
	var response = addFavorite(username, id, function(response){
		res.json(response)
	});
});

app.get("/getFavorites", function (req,res){
	var username = req.query.username
	var response = getFavorites(username, function(results){
		console.log(results)
		res.json(results)
	})
});

app.get("/unfavorite", function (req,res){
	var username = req.query.username
	var id = parseInt(req.query.id)
	var response = unfavorite(username, id, function(response){
		res.json(response)
	})
});
app.get("/addLocation", function (req, res){
	var name = req.query.name
	var address = req.query.address
	var description = req.query.description
	addLocation(name, address, desciption, function(){
		res.json({success: "YES"})
	});
});
//updatePlaces("Student Activity Center");
// MongoClient.connect(url, function(err, db){

// 	console.log("Connected");
// 	database=db

// 	//insertDocuments(db, function() {
// 	//	console.log("This is the callback")
// 	//});

// 	//findStuff(db, function() {
// 	//	console.log("hi");
// 	//	db.close();
// 	//});
// });
app.listen(3000, function() {
	console.log("Listening on 3000");
});
