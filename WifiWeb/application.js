function distanceLabel(distance) {
	if (distance >= 1000) {
		return (Math.floor(distance / 100) / 10) + " Km.";
	} else {
		return Math.floor(distance) + " m.";
	}
}

function placeDistance(place) {
  place = Places[place];
  var lats = ActualLocation.lat - place.lat;
  var lngs = ActualLocation.lng - place.lng;
	
  //Paso a metros
  lats = lats * 60 * 1845;
  lngs = lngs * 60 * 1845;
	
  return Math.sqrt(Math.pow(lats,2)+Math.pow(lngs,2));
}

function loadPlace(place) {
	place = Places[place];
	var output = "";
	output += '<li><h3>Direcci&oacute;n</h3><a href="#">'+place.street+',<br />'+place.zip_code+' '+place.city+'</a></li>';
	output = "<h1>"+place.place+"</h1><ul class='field'>"+output+"</ul>";
	output += '<div id="plastic"><ul class="bigbanner" style="margin:0px;width:296px;"><li class="one" style="background-image: url(images/maps/'+place.md5+'.jpg)"></li></ul></div>';
	output = "<div id='header'><h1>Red</h1><a href='#' id='backButton' onclick='cargaPuntos(); return false;'>Back</a></div>"+output;
	$('place').innerHTML = '';
  $('list').innerHTML = output;
}

function cargaPuntos() {
  var puntos = [];
	var cantidad = 0;
  var distance;
  var todos = Places.length;
  var place;
	var output = "";
  for(i=0; i<todos; i++){
		distance = placeDistance(i);
    if(distance <= 1000) {
			place = Places[i];
			place.distance = distance;
			place.distance_label = distanceLabel(distance);
			place.number = i;
			puntos[cantidad++] = place;
			output += "<li><small>"+place.distance_label+"</small><a href='#' onclick='loadPlace("+place.number+"); return false;'>"+place.place+"</a></li>";
    }
  }
  if (cantidad > 0) {
    output = "<ul>"+output+"</ul>";
  } else {
	output = "No hay ningún punto de acceso de telefónica a menos de 5Km.";
  }
	output = "<div id='header'><h1>Redes ("+cantidad+")</h1></div><h1>Redes a menos de 5 Km.</h1>"+output;
	$('place').innerHTML = '';
  $('list').innerHTML = output;
}

ActualLocation = { lat: null, lng: null };

function getLocation() {
  Device.Location.wait(function(loc) {
		if(!loc) {
		  Device.alert("No se pudo localizar");
			return;
		}
		ActualLocation.lat = loc.lat;
		ActualLocation.lng = loc.lon;
		
		// Coordenadas de prueba
		// ActualLocation.lat = 38.340622;
		// ActualLocation.lng = -0.493149;
		
		cargaPuntos();
		$('loading').style.display = "none";
		$('list').style.display = "";
		$('place').style.display = "";
	});
  return false;
}

window.onload = function() {
  Device.start(getLocation);
}