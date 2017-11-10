function issues2_retire( id1 )
{
  var Popup = {
    open: function(options)
    {
      this.options = {
        url: '#',
        width: 800,
        height: 800
      }
      Object.extend(this.options, options || {});
      window.open(this.options.url, '', 'width='+this.options.width+',height='+this.options.height);
    }
  }
  Popup.open({url:'/cgi/users/home?screen=EPrint::View&eprintid='+id1});

  return false;
}

function issues2_compare( id1, id2 )
{
  if( id1 == null )
  {
    var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&#]*)/gi,
    function(m,key,value)
    {
      if(key == "eprintid") { id1 = value; }
    });
  }

  var win = window.open( '/cgi/users/home?screen=EPrint::Issues2Summary&eprintid='+id1+'&eprintid2='+id2+'&mainonly=yes', 'Compare', 'width=800,height=400' );

  /*
  var Popup = {
    open: function(options)
    {
      this.options = {
        url: '#',
        width: 800,
        height: 400,
        scrollbars: 'yes',
        resizable: 'yes',
        location: 'no',
        name: 'Compare',
      }
      Object.extend(this.options, options || {});
      window.open(this.options.url, '', 'width='+this.options.width+',height='+this.options.height);
    }
  }
  Popup.open({url:'/cgi/users/home?screen=EPrint::Issues2Summary&eprintid='+id1+'&eprintid2='+id2+'&mainonly=yes'});
  */

  return false;
}

function issues2_ack( id1, code )
{
  console.log( id1 + ", " + code );

  if ( confirm( "Acknowledge and dismiss this problem?" ) == true)
  {
    new Ajax.Request( '/cgi/issues2ack?eprintid='+id1+'&code='+code, { method:'get' } );
    return true;
  }
  else
  {
    return false;
  }
}

function issues2_merge(id1, id2)
{
  console.log( "issues2_merge" );

  var fields = "";
  $$('.ep_issues2_merge').each(function(e){
    if($(e).checked==true) {
      fields = fields + $(e).name + ",";
    }
  });

  console.log(id1 + " " + id2 + " " + fields);

  new Ajax.Request( '/cgi/issues2merge?eprintid1='+id1+'&eprintid2='+id2+"&fields="+fields,
  { method:'get',
    onComplete: function() { window.close(); }
  });

  return;
}

// run on page load - hide the issues we are not interested in
document.observe('dom:loaded', function()
{
  var types = [];
  var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi,    
    function(m,key,value)
    {
      if(key == "item_issues2_type")
      {
        types.push( "li.ep_issue_type_" + value );
      }
  });

  if( types.length > 0 )
  {
    // hide all
    $$( "li.ep_issue_type" ).each(
      function (e) { e.setStyle({display:'none'}); } 
    );
    // show selected
    for (i = 0; i < types.length; i++)
    { 
      $$( types[i] ).each(
        function (e) { e.setStyle({display:'list-item'}); } 
      );
    }
  }
});
