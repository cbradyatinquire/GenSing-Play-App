package controllers;

import play.mvc.*;

public class AjaxTesting extends Controller {

    public static void test() {
        renderJSON("hello");
    }

}
