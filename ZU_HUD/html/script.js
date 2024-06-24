$(function() {
    window.addEventListener('message', function(event) {
        if (event.data.type === 'update') {
            updateHUD(event.data);
        } else if (event.data.type === 'toggle') {
            if (event.data.show) {
                $('#hud').stop().fadeIn(300);
            } else {
                $('#hud').stop().fadeOut(300);
            }
        } else if (event.data.type === 'microphone') {
           // console.log('Microphone data received:', event.data);
            updateMicrophone(event.data);
        }
    });
});

function updateHUD(data) {
    if (data.isDead) {
        updateCircle('#hunger', 0);
        updateCircle('#thirst', 0);
    } else {
        updateCircle('#hunger', data.hunger);
        updateCircle('#thirst', data.thirst);
    }
    updateCircle('#health', data.health);
    
    if (data.oxygen < 100) {
        $('#oxygen').show();
        updateCircle('#oxygen', data.oxygen);
    } else {
        $('#oxygen').hide();
    }

    if (data.armor > 0) {
        $('#armor').show();
        updateCircle('#armor', data.armor);
    } else {
        $('#armor').hide();
    }
}

function updateCircle(id, value) {
    value = Math.round(value);
    $(id + ' .circle-fill').css('height', value + '%');
}

function updateMicrophone(data) {
   // console.log('Updating microphone:', data);
    $('#microphone').show();

    if (data.isMicrophoneOn) {
        $('#mic-mute-icon').hide();
        $('#mic-icon').show();
        if (data.isTalking) {
            $('#mic-icon').css('color', '#00ff00');
        } else {
            $('#mic-icon').css('color', '#ffffff');
        }
        let rangeText = ["Chuchoter", "Normal", "Crier"][data.microphoneRange - 1];
       // $('#mic-range').text(rangeText);
        
        // Mettre à jour l'indicateur visuel
        $('.range-bar').removeClass('active');
        for (let i = 0; i < data.microphoneRange; i++) {
        $('.range-bar').eq(i).addClass('active');
        }
    } else {
        $('#mic-icon').hide();
        $('#mic-mute-icon').show().css('color', '#ff0000');
       // $('#mic-range').text('Muet');
        $('.range-bar').removeClass('active');
    }
}