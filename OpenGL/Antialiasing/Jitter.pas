unit Jitter;

interface

uses OpenGL;

type TJitterPoint = record
	   x, y : GLfloat;
  end;
const


MAX_SAMPLES = 66;


// 2 jitter points
j2 : array [0..1] of TJitterPoint =
(
	(x : 0.246490; y :  0.249999),
	(x : -0.246490; y : -0.249999)
);


// 3 jitter points
j3 : array [0..2] of TJitterPoint  =
(
	(x : -0.373411; y : -0.250550),
	(x :  0.256263; y :  0.368119),
	(x :  0.117148; y : -0.117570)
);


// 4 jitter points
j4 : array [0..3] of TJitterPoint =
(
	(x : -0.208147; y :  0.353730),
	(x :  0.203849; y : -0.353780),
	(x : -0.292626; y : -0.149945),
	(x :  0.296924; y :  0.149994)
);


// 8 jitter points
j8 : array [0..7] of TJitterPoint =
(
	(x : -0.334818; y :  0.435331),
	(x :  0.286438; y : -0.393495),
	(x :  0.459462; y :  0.141540),
	(x : -0.414498; y : -0.192829),
	(x : -0.183790; y :  0.082102),
	(x : -0.079263; y : -0.317383),
	(x :  0.102254; y :  0.299133),
	(x :  0.164216; y : -0.054399)
);


// 15 jitter points
j15 : array [0..14] of TJitterPoint =
(
	(x :  0.285561; y :  0.188437),
	(x :  0.360176; y : -0.065688),
	(x : -0.111751; y :  0.275019),
	(x : -0.055918; y : -0.215197),
	(x : -0.080231; y : -0.470965),
	(x :  0.138721; y :  0.409168),
	(x :  0.384120; y :  0.458500),
	(x : -0.454968; y :  0.134088),
	(x :  0.179271; y : -0.331196),
	(x : -0.307049; y : -0.364927),
	(x :  0.105354; y : -0.010099),
	(x : -0.154180; y :  0.021794),
	(x : -0.370135; y : -0.116425),
	(x :  0.451636; y : -0.300013),
	(x : -0.370610; y :  0.387504)
);


// 24 jitter points
j24 : array [0..23] of TJitterPoint =
(
	(x :  0.030245; y :  0.136384),
	(x :  0.018865; y : -0.348867),
	(x : -0.350114; y : -0.472309),
	(x :  0.222181; y :  0.149524),
	(x : -0.393670; y : -0.266873),
	(x :  0.404568; y :  0.230436),
	(x :  0.098381; y :  0.465337),
	(x :  0.462671; y :  0.442116),
	(x :  0.400373; y : -0.212720),
	(x : -0.409988; y :  0.263345),
	(x : -0.115878; y : -0.001981),
	(x :  0.348425; y : -0.009237),
	(x : -0.464016; y :  0.066467),
	(x : -0.138674; y : -0.468006),
	(x :  0.144932; y : -0.022780),
	(x : -0.250195; y :  0.150161),
	(x : -0.181400; y : -0.264219),
	(x :  0.196097; y : -0.234139),
	(x : -0.311082; y : -0.078815),
	(x :  0.268379; y :  0.366778),
	(x : -0.040601; y :  0.327109),
	(x : -0.234392; y :  0.354659),
	(x : -0.003102; y : -0.154402),
	(x :  0.297997; y : -0.417965)
);


// 66 jitter points
j66 : array [0..65] of TJitterPoint =
(
	(x :  0.266377; y : -0.218171),
	(x : -0.170919; y : -0.429368),
	(x :  0.047356; y : -0.387135),
	(x : -0.430063; y :  0.363413),
	(x : -0.221638; y : -0.313768),
	(x :  0.124758; y : -0.197109),
	(x : -0.400021; y :  0.482195),
	(x :  0.247882; y :  0.152010),
	(x : -0.286709; y : -0.470214),
	(x : -0.426790; y :  0.004977),
	(x : -0.361249; y : -0.104549),
	(x : -0.040643; y :  0.123453),
	(x : -0.189296; y :  0.438963),
	(x : -0.453521; y : -0.299889),
	(x :  0.408216; y : -0.457699),
	(x :  0.328973; y : -0.101914),
	(x : -0.055540; y : -0.477952),
	(x :  0.194421; y :  0.453510),
	(x :  0.404051; y :  0.224974),
	(x :  0.310136; y :  0.419700),
	(x : -0.021743; y :  0.403898),
	(x : -0.466210; y :  0.248839),
	(x :  0.341369; y :  0.081490),
	(x :  0.124156; y : -0.016859),
	(x : -0.461321; y : -0.176661),
	(x :  0.013210; y :  0.234401),
	(x :  0.174258; y : -0.311854),
	(x :  0.294061; y :  0.263364),
	(x : -0.114836; y :  0.328189),
	(x :  0.041206; y : -0.106205),
	(x :  0.079227; y :  0.345021),
	(x : -0.109319; y : -0.242380),
	(x :  0.425005; y : -0.332397),
	(x :  0.009146; y :  0.015098),
	(x : -0.339084; y : -0.355707),
	(x : -0.224596; y : -0.189548),
	(x :  0.083475; y :  0.117028),
	(x :  0.295962; y : -0.334699),
	(x :  0.452998; y :  0.025397),
	(x :  0.206511; y : -0.104668),
	(x :  0.447544; y : -0.096004),
	(x : -0.108006; y : -0.002471),
	(x : -0.380810; y :  0.130036),
	(x : -0.242440; y :  0.186934),
	(x : -0.200363; y :  0.070863),
	(x : -0.344844; y : -0.230814),
	(x :  0.408660; y :  0.345826),
	(x : -0.233016; y :  0.305203),
	(x :  0.158475; y : -0.430762),
	(x :  0.486972; y :  0.139163),
	(x : -0.301610; y :  0.009319),
	(x :  0.282245; y : -0.458671),
	(x :  0.482046; y :  0.443890),
	(x : -0.121527; y :  0.210223),
	(x : -0.477606; y : -0.424878),
	(x : -0.083941; y : -0.121440),
	(x : -0.345773; y :  0.253779),
	(x :  0.234646; y :  0.034549),
	(x :  0.394102; y : -0.210901),
	(x : -0.312571; y :  0.397656),
	(x :  0.200906; y :  0.333293),
	(x :  0.018703; y : -0.261792),
	(x : -0.209349; y : -0.065383),
	(x :  0.076248; y :  0.478538),
	(x : -0.073036; y : -0.355064),
	(x :  0.145087; y :  0.221726)
);

implementation

end.