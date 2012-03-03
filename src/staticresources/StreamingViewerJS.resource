(function(global) {
    global.TopicSubscription = TopicSubscription;
    function TopicSubscription(name, checkbox) {
        if (TopicSubscription.all[name]) {
            throw new Error('Subscription already exists. :' + name);
        }
        this.subscribed = null;
        this.subscription = null;
        this.name = name;
        this.checkbox = checkbox;
        this.setClickListener();
        TopicSubscription.all[name] = this;
    }
    TopicSubscription.notifier = function(message) {console.log(message)};
    TopicSubscription.topics = [];
    TopicSubscription.all = {};
    TopicSubscription.init = function() {
        var topics = this.topics;
        for (var i = 0, len = topics.length; i < len; i++) {
            var t = topics[i];
            new TopicSubscription(t.name, t.checkbox);
        }
        this.forAll(true);
    };
    TopicSubscription.clear = function() {
        this.forAll(false);
        this.topics = [];
        this.all = {};
    };
    TopicSubscription.forAll = function(subscribe) {
        var fn = (subscribe ? '' : 'un') + 'subscribe';
        jQuery.each(this.all, callSubscribeFn);
        function callSubscribeFn(i, subscription) {
            if ((subscribe && ! subscription.subscribed) ||
                (! subscribe && subscription.subscribed)) {
                subscription[fn]();
            }
        }
        document.getElementById('subscribeAll').checked = subscribe;
    }
    TopicSubscription.prototype.setClickListener = function() {
        var that = this;
        this.checkbox.onclick = function() {
            if (that.subscribed) {
                that.unsubscribe();
            } else {
                that.subscribe();
            }
        };
    };
    TopicSubscription.prototype.subscribe = function() {
        this.subscription = jQuery.cometd.subscribe('/topic/' + this.name, onSubscribed);
        this.checkbox.checked = true;
        this.subscribed = true;
        function onSubscribed(message) {
            console.log(message);
            try {
                TopicSubscription.notifier(message);
            } catch (e) {
                console.log(e);
            }
        }
    };
    TopicSubscription.prototype.unsubscribe = function() {
        jQuery.cometd.unsubscribe(this.subscription);
        this.checkbox.checked = false;
        this.subscribed = false;
    }
}(this));