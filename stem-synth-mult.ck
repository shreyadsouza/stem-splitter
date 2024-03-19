// create our OSC receiver
OscIn oscin;
// a thing to retrieve message contents
OscMsg msg;
// use port 12000 (default Wekinator output port)
12000 => oscin.port;
Hid hi;
HidMsg keymsg;

1 => float multiplier;

1 => int device;
if( !hi.openKeyboard( device ) ) me.exit();



"localhost" => string hostname;
9990 => int proscessing_port;


OscOut xmit;

xmit.dest( hostname, proscessing_port );




// listen for "/wek/output" message with 4 floats coming in
oscin.addAddress( "/wek/outputs, ffff" );
// print
<<< "listening for OSC message from Wekinator on port 12000...", "" >>>;
<<< " |- expecting \"/wek/outputs\" with 4 continuous parameters...", "" >>>; 

// expecting 4 output dimensions
4 => int NUM_PARAMS;
float myParams[NUM_PARAMS];
0 => int song_ind;


// envelopes for smoothing parameters
// (alternately, can use slewing interpolators; SEE:
// https://chuck.stanford.edu/doc/examples/vector/interpolate.ck)
Envelope envs[NUM_PARAMS];
for( 0 => int i; i < NUM_PARAMS; i++ )
{
    envs[i] => blackhole;
    .25 => envs[i].value;
    10::ms => envs[i].duration;
}

SndBuf sounds[NUM_PARAMS];
["smile", "monkeys", "evergreen", "ken"] @=> string songs[];
for (auto buf : sounds) buf => dac;

fun void initialize(int pos){
    <<<songs[song_ind]>>>;
    [   
        me.dir() + "scripts/separated/htdemucs/"+songs[song_ind]+"/other.wav",
        me.dir() + "scripts/separated/htdemucs/"+songs[song_ind]+"/vocals.wav",
        me.dir() + "scripts/separated/htdemucs/"+songs[song_ind]+"/drums.wav",
        me.dir() + "scripts/separated/htdemucs/"+songs[song_ind]+"/bass.wav",
    ] @=> string files[];

    for (0 => int i; i < NUM_PARAMS; i++){
        files[i] => sounds[i].read;
        pos => sounds[i].pos;
    }

     // start the message...
    xmit.start("/video/song");
    // add float argument
    song_ind => xmit.add;
    // send it
    xmit.send();

}


// send OSC message: current file index and startTime, uniquely identifying a window
fun void sendWindow( float startTime )
{
    // start the message...
    xmit.start("/video/pos");
    // add float argument
    startTime => xmit.add;
    // send it
    xmit.send();
    for (0 => int i; i < NUM_PARAMS; i++){  
        (startTime::second/samp)$ int=> sounds[i].pos;
    }
}

// send OSC message: current file index and startTime, uniquely identifying a window
fun void sendSpeed()
{
    // start the message...
    xmit.start("/video/speed");
    // add float argument
    multiplier => xmit.add;
    // send it
    xmit.send();
    for (0 => int i; i < NUM_PARAMS; i++){  
        sounds[i].rate(multiplier);
    }
}


fun void setParams( float params[] )
{
    // make sure we have enough
    if(params.size() >= NUM_PARAMS)
    {		
        // adjust the synthesis accordingly
        0.0 => float x;
        for( 0 => int i; i < NUM_PARAMS; i++ )
        {
            // get value
            params[i] => x;
            // clamp it
            if( x < 0 ) 0 => x;
            if( x > 1 ) 1 => x;
            // set as target of envelope (for smoothing)
            x => envs[i].target;
            // remember
            x => myParams[i];
        }
    }
}

// function to map incoming parameters to musical parameters
fun void map2sound()
{
    // time loop
    while( true )
    {   
        // make sure we have enough
        for (0 => int i; i < NUM_PARAMS; i++){
            envs[i].value() * .5 => sounds[i].gain;
        }
        10::ms => now;
    }
}

fun void waitForEvent()
{
    // array to hold params
    float p[NUM_PARAMS];
    

    // infinite event loop
    while(true)
    {
        // wait for OSC message to arrive
        oscin => now;
        // grab the next message from the queue. 
        while(oscin.recv(msg))
        {
            // print stuff
            cherr <= msg.address <= " ";
            // unpack our 5 floats into our array p
            for( int i; i < NUM_PARAMS; i++ )
            {
                // put into array
                msg.getFloat(i) => p[i];
                // print
                cherr <= p[i] <= " ";
            }
            cherr <= IO.newline();
            // set the parameters
            setParams( p );
        }
    }
}


fun void keyboardInput() {
    // infinite event loop
while( true )
{
    // wait on event
    hi => now;
    // get one or more messages
    while(hi.recv(keymsg))
    {
        // check for action type
        if( keymsg.isButtonDown() )
        {
            if (keymsg.key==79){
                for (0 => int i; i < NUM_PARAMS; i++){  
                    sounds[i].phaseOffset(0.1);
                }
                sounds[0].pos()/44100.0 => float progress;
                sendWindow(progress);
            } 
            if (keymsg.key==82){
                1.2 *=> multiplier;
                sendSpeed();
            }
            if (keymsg.key==81){
                0.8 *=> multiplier;
                sendSpeed();
            }
            if (keymsg.key==44){
                while (Math.random2(0, songs.size()-1) == song_ind){
                    Math.random2(0, songs.size()-1) => song_ind;

                }
                // 1 => song_ind;
                initialize(sounds[0].pos());
            }
            else{
                <<<keymsg.key>>>;
            }
        }  
    }
}

}

initialize(0);
sendWindow(0);

// spork osc receiver loop
spork ~waitForEvent();
// spork mapping function
spork ~ map2sound();	

spork ~ keyboardInput();
// // turn on sound
// soundOn();

// time loop to keep everything going
while( true ) 1::second => now;
