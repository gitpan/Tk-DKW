package Tk::Columns;

use Tk;

use Tk::TiedListbox;
use Tk::Scrollbar;
use Tk::Frame;
use Tk::Pane;

use vars qw ($VERSION @ISA);

use strict;

$VERSION = '1.01';

@ISA = qw (Tk::Derived Tk::Frame);

Tk::Widget->Construct ('Columns');

*columnlabels = \&columns;
*addcolumn = \&column;

sub ClassInit
   {
    my ($p_Class, $p_Window) = (@_);
    $p_Window->bind ($p_Class, '<Configure>', 'Refresh');
    $p_Window->bind ($p_Class, '<Expose>', 'Refresh');
    $p_Window->bind ($p_Class, '<Map>', 'Refresh');
    return $p_Class;
   }

sub Populate
   {
    my ($this) = (shift, @_);

    my $l_Pane = $this->Component
       (
        'Pane' => 'Pane',
        '-relief' => 'groove',
        '-borderwidth' => 2,
       );

    my $l_ButtonFrame = $l_Pane->Component
       (
        'Frame' => 'ButtonFrame',
        '-height' => 30,
       );

    my $l_ListFrame = $l_Pane->Component
       (
        'Frame' => 'ListFrame',
       );

    my $l_HorizontalScrollbar = $this->Component
       (
        'Scrollbar' => 'HorizontalScrollbar',
        '-orient' => 'horizontal',
        '-borderwidth' => 1,
       );

    my $l_VerticalScrollbar = $this->Component
       (
        'Scrollbar' => 'VerticalScrollbar',
        '-orient' => 'vertical',
        '-borderwidth' => 1,
       );

    my $l_UpperRightFiller = $this->Component
       (
        'Frame' => 'UpperRightFiller',
        '-borderwidth' => 1,
        '-relief' => 'raised',
       );

    my $l_LowerRightFiller = $this->Component
       (
        'Frame' => 'LowerRightFiller',
       );

    my $l_FillerButton = $l_ButtonFrame->Component
       (
        'Frame' => 'FillerButton',
        '-relief' => 'raised',
        '-borderwidth' => 1,
        '-width' => 100,
       );

    my $l_FillerFrame = $l_ListFrame->Component
       (
        'Frame' => 'FillerFrame',
        '-background' => 'white',
        '-borderwidth' => 1,
        '-relief' => 'flat',
        '-width' => 100,
       );

    $this->{m_AvgHeight} = 22;

    $l_ButtonFrame->pack
       (
        '-side' => 'right',
        '-fill' => 'both',
        '-expand' => 'true',
       );

    $this->SUPER::Populate (@_);

    $this->ConfigSpecs
       (
        '-selectmode' => [['SELF', 'PASSIVE'], 'Selectmode', 'Selectmode', 'single'],
        '-listbackground' => [['SELF', 'PASSIVE'], 'listBackground', 'ListBackground', 'white'],
        '-trimcount' => [['SELF', 'PASSIVE'], 'trimCount', 'TrimCount', 2],
        '-columnlabels' => ['METHOD'],
        '-command' => ['METHOD'],
        '-columns' => ['METHOD'],
        '-column' => ['METHOD'],
       );

    $l_HorizontalScrollbar->configure
       (
        '-command' => sub
           {
            $l_Pane->xview (@_);
            Tk::break;  # Prevents cascading feedback loop with xscrollcommand (!)
           }
       );

    $l_Pane->configure
       (
        '-borderwidth' => 0,

        '-xscrollcommand' => sub
           {
            $l_HorizontalScrollbar->set (@_);
           }
       );

    $this->GeometryRequest (300, 200);
    return $this;
   }

sub Refresh
   {
    my ($this) = (shift, @_);

    my @l_Lists =
       (
        $#{$this->{m_ListList}} > -1 ?
        @{$this->{m_ListList}} :
        ()
       );

    my $l_HorizontalHeight = 0;
    my $l_VerticalWidth = 0;
    my $l_TotalWidth = 0;

    my ($l_Pane, $l_Horizontal, $l_UpperRightFiller, $l_Vertical, $l_LowerRightFiller) =
       (
        $this->Subwidget ('Pane'),
        $this->Subwidget ('HorizontalScrollbar'),
        $this->Subwidget ('UpperRightFiller'),
        $this->Subwidget ('VerticalScrollbar'),
        $this->Subwidget ('LowerRightFiller'),
       );

    my ($l_ButtonFrame, $l_ListFrame) =
       (
        $l_Pane->Subwidget ('ButtonFrame'),
        $l_Pane->Subwidget ('ListFrame'),
       );

    my ($l_FillerButton, $l_FillerFrame) =
       (
        $l_ButtonFrame->Subwidget ('FillerButton'),
        $l_ListFrame->Subwidget ('FillerFrame'),
       );

    $l_ButtonFrame->pack
       (
        '-expand' => 'true',
        '-anchor' => 'nw',
        '-side' => 'top',
        '-fill' => 'x',
       );

    $l_ListFrame->pack
       (
        '-expand' => 'true',
        '-anchor' => 'sw',
        '-side' => 'bottom',
        '-fill' => 'both',
       );

    if ($l_Horizontal->Needed() && ! $l_FillerButton->IsMapped() && $l_Vertical->Needed())
       {
        $l_Horizontal->place
           (
            '-width' => - $l_Vertical->reqwidth(),
            '-relwidth' => 1.0,
            '-anchor' => 'sw',
            '-rely' => 1.0,
            '-x' => 0,
           );

        $l_Vertical->place
           (
            '-anchor' => 'ne',
            '-relx' => 1.0,
            '-relheight' => 1.0,
            '-y' => $l_ButtonFrame->reqheight(),
            '-height' => - ($l_Horizontal->reqheight() + $l_ButtonFrame->reqheight()),
           );

        $l_UpperRightFiller->place
           (
            '-height' => $l_ButtonFrame->reqheight(),
            '-width' => $l_Vertical->reqwidth(),
            '-anchor' => 'ne',
            '-relx' => 1.0,
           );

        $l_LowerRightFiller->place
           (
            '-height' => $l_Horizontal->reqheight(),
            '-width' => $l_Vertical->reqwidth(),
            '-anchor' => 'se',
            '-relx' => 1.0,
            '-rely' => 1.0,
           );

        $l_HorizontalHeight = $l_Horizontal->reqheight();
        $l_VerticalWidth = $l_Vertical->reqwidth();
       }
    elsif ($l_Horizontal->Needed() && ! $l_FillerButton->IsMapped())
       {
        $l_UpperRightFiller->placeForget();
        $l_LowerRightFiller->placeForget();
        $l_Vertical->placeForget();

        $l_Horizontal->place
           (
            '-width' => undef,
            '-relwidth' => 1.0,
            '-anchor' => 'sw',
            '-rely' => 1.0,
            '-x' => 0,
           );

        $l_HorizontalHeight = $l_Horizontal->reqheight();
       }
    elsif ($l_Vertical->Needed() && $#l_Lists > -1)
       {
        $l_LowerRightFiller->placeForget();
        $l_Horizontal->placeForget();

        $l_UpperRightFiller->place
           (
            '-height' => $l_ButtonFrame->reqheight(),
            '-width' => $l_Vertical->reqwidth(),
            '-anchor' => 'ne',
            '-relx' => 1.0,
           );
 
        $l_Vertical->place
           (
            '-height' => - $l_ButtonFrame->reqheight(),
            '-y' => $l_ButtonFrame->reqheight(),
            '-relheight' => 1.0,
            '-relx' => 1.0,
           );

        $l_VerticalWidth = $l_Vertical->reqwidth();
       }
    else
       {
        $l_UpperRightFiller->placeForget();
        $l_LowerRightFiller->placeForget();
        $l_Horizontal->placeForget();
        $l_Vertical->placeForget();
       }

    $l_Pane->place
       (
        '-x' => 0,
        '-y' => 0,
        '-relwidth' => 1.0,
        '-relheight' => 1.0,
        '-width' => - $l_VerticalWidth,
        '-height' => - $l_HorizontalHeight,
       );

    my $l_ListHeight =
       (
        $this->height() -
        ($l_HorizontalHeight ? $l_Horizontal->reqheight() : 0) -
        $l_ButtonFrame->reqheight()
       );

    foreach my $l_List (@l_Lists)
       {
        $l_List->GeometryRequest
           (
            $l_List->{m_Button}->reqwidth(),
            $l_ListHeight,
           );

        $l_TotalWidth += $l_List->{m_Button}->reqwidth();
       }

    my $l_Gap =
       (
        $this->width() -
        ($l_VerticalWidth > 0 ? $l_Vertical->reqwidth() : 0) -
        $l_TotalWidth
       );

    if ($l_Gap > 0)
       {
        my $l_ButtonHeight =
           (
            $l_TotalWidth < 1 ?
            $this->{m_AvgHeight} :
            $l_ButtonFrame->reqheight()
           );

        my $l_FrameHeight =
           (
            $l_TotalWidth < 1 ?
            $this->reqheight() - $l_ButtonHeight :
            $l_ListFrame->reqheight()
           );

        $l_FillerButton->GeometryRequest
           (
            $l_Gap,
            $l_ButtonHeight
           );

        $l_FillerFrame->GeometryRequest
           (
            $l_Gap,
            $l_FrameHeight
           );

        $l_FillerButton->configure
           (
            '-width' => $l_Gap,
            '-height' => $l_ButtonHeight,
           );

        $l_FillerFrame->configure
           (
            '-width' => $l_Gap,
            '-height' => $l_FrameHeight
           );

        $l_FillerButton->pack
           (
            '-side' => 'right',
            '-anchor' => 'ne',
            '-fill' => 'both',
           );

        $l_FillerFrame->pack
           (
            '-side' => 'right',
            '-anchor' => 'ne',
            '-fill' => 'both',
           );
       }
    else
       {
        $l_FillerButton->packForget();
        $l_FillerFrame->packForget();
       }
   }

sub deletecolumns
   {
    my ($this) = (shift, @_);

    my ($l_Pane) =
       (
        $this->Subwidget ('Pane'),
       );

    my ($l_ButtonFrame, $l_ListFrame) =
       (
        $l_Pane->Subwidget ('ButtonFrame'),
        $l_Pane->Subwidget ('ListFrame'),
       );

    foreach my $l_Widget ($l_ButtonFrame->children(), $l_ListFrame->children())
       {
        $l_Widget->destroy() if (! ($l_Widget->name() =~ /^filler/));
       }

    $this->ConfigSpecs("DEFAULT" => []);
    $this->Delegates (DEFAULT => undef);
    undef $this->{m_ButtonList};
    undef $this->{m_ListList};
    $this->Refresh();
   }

sub columns
   {
    my ($this, $p_ColumnList) = (shift, @_);

    $this->deletecolumns();

    foreach my $l_Name (@{$p_ColumnList})
       {
        $this->column ($l_Name);
       }
   }

sub command
   {
    my ($this, $p_Callback) = (shift, @_);

    $this->{m_Callback} = $p_Callback;
   }

sub column
   {
    my ($this, $p_ColumnName, $p_Arguments) = (shift, @_);

    my $l_Count = $this->cget ('-trimcount') || 2;

    my ($l_Pane, $l_Horizontal, $l_UpperRightFiller, $l_Vertical, $l_LowerRightFiller) =
       (
        $this->Subwidget ('Pane'),
        $this->Subwidget ('HorizontalScrollbar'),
        $this->Subwidget ('UpperRightFiller'),
        $this->Subwidget ('VerticalScrollbar'),
        $this->Subwidget ('LowerRightFiller'),
       );

    my ($l_ButtonFrame, $l_ListFrame) =
       (
        $l_Pane->Subwidget ('ButtonFrame'),
        $l_Pane->Subwidget ('ListFrame'),
       );

    my $l_Button = $l_ButtonFrame->Frame
       (
        '-relief' => 'raised',
        '-borderwidth' => 1,
        '-width' => 100,
       );

    my $l_LabelWidget = $l_Button->Component
       (
        'Label' => 'Label',
        '-text' => $p_ColumnName,
       );

    my $l_List = $l_ListFrame->Listbox
       (
        '-background' => $this->cget ('-listbackground'),
        '-relief' => 'flat',
        '-exportselection' => 0,
        '-height' => 20,
        '-borderwidth' => 0,
        '-width' => 100,
       );

    $l_LabelWidget->bind ('<ButtonRelease-1>' => sub {$this->ButtonRelease ($l_Button);});
    $l_LabelWidget->bind ('<ButtonPress-1>' => sub {$this->ButtonPress ($l_Button);});
    $l_LabelWidget->bind ('<Motion>' => sub {$this->ButtonOver ($l_Button);});

    $l_Button->bind ('<ButtonRelease-1>' => sub {$this->ButtonRelease ($l_Button);});
    $l_Button->bind ('<ButtonPress-1>' => sub {$this->ButtonPress ($l_Button);});
    $l_Button->bind ('<Motion>' => sub {$this->ButtonOver ($l_Button);});

    for (my $l_Index = 0; $l_Index < $l_Count; ++$l_Index)
       {
        my $l_Widget = $l_Button->Component
           (
            'Frame' => 'Trim_'.$l_Index,
            '-background' => 'white',
            '-relief' => 'raised',
            '-borderwidth' => 2,
            '-width' => 2,
           );

        $l_Widget->place
           (
            '-x' => - ($l_Index * 3 + 2),
            '-relheight' => 1.0,
            '-anchor' => 'ne',
            '-height' => - 4,
            '-relx' => 1.0,
            '-y' => 2,
           );

        $l_Widget->bind ('<ButtonRelease-1>' => sub {$this->ButtonRelease ($l_Button, 1);});
        $l_Widget->bind ('<ButtonPress-1>' => sub {$this->ButtonPress ($l_Button, 1);});
        $l_Widget->bind ('<Motion>' => sub {$this->ButtonOver ($l_Button, 1);});
        $l_Button->{m_LastTrim} = $l_Widget;
       }

    $l_LabelWidget->place
       (
        '-x' => 4,
        '-width' => -8,
        '-y' => 0,
        '-relheight' => 1.0,
        '-relwidth' => 1.0,
       );

    $l_Button->configure
       (
        '-height' => ($this->{m_AvgHeight} = $l_LabelWidget->reqheight() + ($l_Button->cget ('-borderwidth') * 4)),
        '-width' => 80 + $l_LabelWidget->reqwidth() + ($l_Button->cget ('-borderwidth') * 4),
       );

    $l_Button->pack
       (
        '-side' => 'left',
        '-anchor' => 'nw',
        '-fill' => 'y',
       );

    $l_List->pack
       (
        '-anchor' => 'nw',
        '-side' => 'left',
        '-expand' => 'true',
        '-fill' => 'y',
       );

    $l_Button->bind
       (
        '<Configure>' => sub
           {
            $l_Button->{m_List}->GeometryRequest
               (
                $l_Button->reqwidth(),
                $l_Button->{m_List}->reqheight(),
               );
           }
       );

    $l_List->bind
       (
        '<Double-ButtonPress-1>' => sub
           {
            my @l_Selection = $l_List->curselection();

            if (defined ($this->{m_Callback}) && $#l_Selection > -1)
               {
                &{$this->{m_Callback}} ($this->get ($l_Selection [0]));
               }
           }
       );

    ($l_List->{m_Button} = $l_Button)->{m_List} = $l_List;
    push (@{$this->{m_ButtonList}}, $l_Button);
    push (@{$this->{m_ListList}}, $l_List);
    $this->DoScrollbarBindings();
    $this->Refresh();
   }

sub DoScrollbarBindings
   {
    my $this = shift;

    my $l_Scrollbar = $this->Subwidget ('VerticalScrollbar');
    my @l_Lists = @{$this->{m_ListList}};

    $l_Scrollbar->configure
       (
        '-command' => sub
           {
            $l_Lists[0]->yview (@_);
            Tk::break;  # Prevents cascading feedback loop with yscrollcommand (!)
           }
       );

    $l_Lists[0]->configure
       (
        '-yscrollcommand' => sub
           {
            $l_Scrollbar->set (@_);
           }
       );

    $l_Lists[0]->tie ('all', [@l_Lists [1..$#l_Lists]]);
    $this->ConfigSpecs("DEFAULT" => [$l_Lists[0]]);
    $this->Delegates ('DEFAULT' => $l_Lists[0]);
   }

sub SortColumn
   {
    my ($this, $p_Button) = (shift, @_);
    my @l_Lists = @{$this->{m_ListList}};
    my $l_CurrentList = $p_Button->{m_List};
    my $l_Size = $l_CurrentList->size();
    my @l_SortedKeys = ();
    my @l_Sorted = ();
    my %l_Keys;

    for (my $l_Index = 0; $l_Index < $l_Size; ++$l_Index)
       {
        push (@{$l_Keys {$l_CurrentList->get ($l_Index)}}, $l_Index);
       }

    if ($p_Button->{m_Order})
       {
        @l_SortedKeys = (sort {$a cmp $b} (keys %l_Keys));
       }
    else
       {
        @l_SortedKeys = (sort {$b cmp $a} (keys %l_Keys));
       }

    $p_Button->{m_Order} = ! $p_Button->{m_Order};

    foreach my $l_Key (@l_SortedKeys)
       {
        foreach my $l_Index (@{$l_Keys {$l_Key}})
           {
            push (@l_Sorted, [$this->get ($l_Index)]);
           }
       }

    while ($this->size())
       {
        $this->delete ('end');
       }

    foreach my $l_Ref (@l_Sorted)
       {
        $this->insert ('end', @{$l_Ref});
       }

    $this->Refresh();
   }

sub insert
   {
    my ($this, $p_Where, @p_Elements) = (shift, @_);

    foreach my $l_List (@{$this->{m_ListList}})
       {
        $l_List->insert ($p_Where, shift @p_Elements);
       }

    $this->Refresh();
   }

sub get
   {
    my ($this, $p_Where) = (shift, @_);
    my @l_Return = ();

    foreach my $l_List (@{$this->{m_ListList}})
       {
        push (@l_Return, $l_List->get ($p_Where));
       }

    return @l_Return;
   }

sub delete
   {
    my ($this, @p_Where) = (shift, @_);

    foreach my $l_List (@{$this->{m_ListList}})
       {
        $l_List->delete (@p_Where);
       }

    $this->Refresh();
   }

sub ButtonEdgeSelected
   {
    return ($_[1]->pointerx() - $_[1]->{m_LastTrim}->rootx()) > -1;
   }

sub ButtonOver
   {
    my ($this, $p_Button, $p_Trim) = (shift, @_);

    $p_Button->configure
       (
        '-cursor' =>
           (
            $this->ButtonEdgeSelected ($p_Button) || $p_Trim ?
            'sb_h_double_arrow' :
            $this->cget ('-cursor')
           )
       );
   }

sub ButtonPress
   {
    my ($this, $p_Button, $p_Trim) = (shift, @_);

    if ($this->ButtonEdgeSelected ($p_Button) || $p_Trim)
       {
        $p_Button->{m_X} = $p_Button->pointerx() - $p_Button->rootx();
       }
    else
       {
        $p_Button->configure ('-relief' => 'sunken');
        $p_Button->{m_X} = -1;
       }
   }

sub ButtonRelease
   {
    my ($this, $p_Button, $p_Trim) = (shift, @_);

    if ($p_Button->{m_X} >= 0)
       {
        my $l_NewWidth =
           (
            $p_Button->pointerx() -
            $p_Button->rootx() -
            $p_Button->{m_X} +
            $p_Button->reqwidth()
           );

        my $l_TrimWidth =
           (
            $p_Button->reqwidth() -
            ($p_Button->{m_LastTrim}->rootx() - $p_Button->rootx())
           );

        if ($l_TrimWidth > $l_NewWidth)
           {
            $l_NewWidth = $l_TrimWidth;
           }

        $p_Button->GeometryRequest
           (
            $l_NewWidth,
            $p_Button->reqheight(),
           );

        $p_Button->configure
           (
            '-width' => $l_NewWidth
           );

        $this->Refresh();
       }
    elsif (! $this->ButtonEdgeSelected ($p_Button))
       {
        $this->SortColumn ($p_Button);
       }

    $p_Button->configure ('-relief' => 'raised');
    $p_Button->{m_X} = -1;
   }

1;

__END__

=cut

=head1 NAME

Tk::Columns - A multicolumn list widget with sortable & sizeable columns

=head1 SYNOPSIS

    use Tk;

    my $MainWindow = MainWindow->new();

    Tk::MainLoop;

=head1 DESCRIPTION

A multicolumn list widget with resizeable borders and sorting by column.

=head1 AUTHORS

Damion K. Wilson, dkw@rcm.bm

=head1 HISTORY 
 
=cut