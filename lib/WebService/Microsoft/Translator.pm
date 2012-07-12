package WebService::Microsoft::Translator;
use strict;
use warnings;
no warnings 'utf8';
use Web::UserAgent::Functions;
use Encode;

sub new {
    my $class = shift;
    my %args = @_;

    my $self = {
        app_id  => $args{'app_id'},
        onerror => $args{onerror},
    };

    return bless $self, $class;
}

sub onerror {
    my $self = shift;
    if (@_) {
        $self->{onerror} = $_[0];
    }
    return $self->{onerror} || sub {
        my %args = @_;
        warn $args{message};
    };
}

sub translate {
    my $self = shift;
    my %args = @_;

    my $from = $args{from} || '';
    my $to = $args{to} || die "|to| parameter is not specified";
    my $text = $args{text} || die "|text| parameter is not specified";

    my ($req, $res) = http_get(
        url     => q<http://api.microsofttranslator.com/V2/Ajax.svc/Translate>,
        params  => {
            appId   => $self->{app_id},
            from    => $from,
            to      => $to,
            text    => encode_utf8($self->encode_system_string($text)),
        }
    );

    if ($res->is_error) {
        return undef;
    }

    my $returned_text = decode('utf-8', $res->content);
    $returned_text =~ s{^\x{FEFF}}{};
    my $decoded_text = $self->decode_system_string($returned_text);
    if (not defined $decoded_text) {
        my $onerror = $self->onerror;
        $returned_text =~ s{^"}{};
        $returned_text =~ s{"$}{};
        if ($returned_text =~ /ArgumentOutOfRangeException: 'from' must be a valid language/) {
            $onerror->(type => 'cannot-detect-from',
                       message => $returned_text);
        } else {
            $onerror->(message => $returned_text);
        }
    }
    return $decoded_text;
}

sub encode_system_string {
    my ($class, $text) = @_;
    return "_. " . $text;
}

sub decode_system_string {
    my ($class, $text) = @_;
    if ($text =~ m{^"_\.?\s*} and $text =~ m{"$}) {
        $text =~ s{^"_\.?\s*}{};
        $text =~ s{"$}{};
        $text =~ s{\\u([0-9A-Fa-f]{4})}{chr hex $1}ge;
        return $text;
    } else {
        return undef;
    }
}

1;
