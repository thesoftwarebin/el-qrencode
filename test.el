(require 'ert)

(ert-deftest
    test-01-copy-and-mask () "test copy-and-mask on a 21x21 matrix"
    (should
     (equal
     (copy-and-mask [[:fdark :fdark :fdark :fdark :fdark :fdark :fdark :flight :reserve :light :dark :dark :dark :flight :fdark :fdark :fdark :fdark :fdark :fdark :fdark]
                     [:fdark :flight :flight :flight :flight :flight :fdark :flight :reserve :dark :light :light :dark :flight :fdark :flight :flight :flight :flight :flight :fdark]
                     [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :reserve :dark :light :dark :light :flight :fdark :flight :fdark :fdark :fdark :flight :fdark]
                     [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :reserve :dark :light :light :dark :flight :fdark :flight :fdark :fdark :fdark :flight :fdark]
                     [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :reserve :dark :light :light :light :flight :fdark :flight :fdark :fdark :fdark :flight :fdark]
                     [:fdark :flight :flight :flight :flight :flight :fdark :flight :reserve :light :light :dark :dark :flight :fdark :flight :flight :flight :flight :flight :fdark]
                     [:fdark :fdark :fdark :fdark :fdark :fdark :fdark :flight :fdark :flight :fdark :flight :fdark :flight :fdark :fdark :fdark :fdark :fdark :fdark :fdark]
                     [:flight :flight :flight :flight :flight :flight :flight :flight :reserve :dark :light :light :dark :flight :flight :flight :flight :flight :flight :flight :flight]
                     [:reserve :reserve :reserve :reserve :reserve :reserve :fdark :reserve :reserve :dark :light :dark :dark :reserve :reserve :reserve :reserve :reserve :reserve :reserve :reserve]
                     [:dark :dark :light :light :dark :light :flight :light :dark :dark :dark :dark :light :dark :dark :dark :light :light :dark :light :dark]
                     [:dark :dark :dark :dark :dark :light :fdark :dark :dark :dark :light :light :light :light :dark :light :light :dark :light :dark :light]
                     [:dark :dark :light :light :light :light :flight :light :light :dark :light :dark :light :dark :dark :dark :light :dark :light :dark :dark]
                     [:dark :dark :dark :light :dark :dark :fdark :dark :dark :dark :light :light :light :light :light :light :light :light :dark :light :light]
                     [:flight :flight :flight :flight :flight :flight :flight :flight :fdark :light :dark :light :light :light :light :light :light :light :light :light :dark]
                     [:fdark :fdark :fdark :fdark :fdark :fdark :fdark :flight :reserve :dark :light :dark :dark :dark :light :dark :dark :dark :light :dark :light]
                     [:fdark :flight :flight :flight :flight :flight :fdark :flight :reserve :light :light :light :dark :light :light :light :dark :dark :light :light :light]
                     [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :reserve :light :dark :dark :dark :dark :light :dark :dark :light :dark :dark :light]
                     [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :reserve :light :dark :dark :light :dark :dark :light :light :dark :dark :light :light]
                     [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :reserve :light :light :light :light :light :dark :light :light :dark :dark :light :light]
                     [:fdark :flight :flight :flight :flight :flight :fdark :flight :reserve :dark :dark :dark :light :dark :dark :light :light :light :light :light :light]
                     [:fdark :fdark :fdark :fdark :fdark :fdark :fdark :flight :reserve :light :dark :light :light :light :light :light :light :light :light :dark :light]]
                    21 :level-m 0)
     (list
      [[:fdark :fdark :fdark :fdark :fdark :fdark :fdark :flight :flight :light :light :dark :light :flight :fdark :fdark :fdark :fdark :fdark :fdark :fdark]
       [:fdark :flight :flight :flight :flight :flight :fdark :flight :fdark :light :light :dark :dark :flight :fdark :flight :flight :flight :flight :flight :fdark]
       [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :flight :dark :dark :dark :dark :flight :fdark :flight :fdark :fdark :fdark :flight :fdark]
       [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :flight :light :light :dark :dark :flight :fdark :flight :fdark :fdark :fdark :flight :fdark]
       [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :fdark :dark :dark :light :dark :flight :fdark :flight :fdark :fdark :fdark :flight :fdark]
       [:fdark :flight :flight :flight :flight :flight :fdark :flight :flight :dark :light :light :dark :flight :fdark :flight :flight :flight :flight :flight :fdark]
       [:fdark :fdark :fdark :fdark :fdark :fdark :fdark :flight :fdark :flight :fdark :flight :fdark :flight :fdark :fdark :fdark :fdark :fdark :fdark :fdark]
       [:flight :flight :flight :flight :flight :flight :flight :flight :flight :light :light :dark :dark :flight :flight :flight :flight :flight :flight :flight :flight]
       [:fdark :flight :fdark :flight :fdark :flight :fdark :flight :flight :dark :dark :dark :light :flight :flight :flight :fdark :flight :flight :fdark :flight]
       [:dark :light :light :dark :dark :dark :flight :dark :dark :light :dark :light :light :light :dark :light :light :dark :dark :dark :dark]
       [:light :dark :light :dark :light :light :fdark :dark :light :dark :dark :light :dark :light :light :light :dark :dark :dark :dark :dark]
       [:dark :light :light :dark :light :dark :flight :dark :light :light :light :light :light :light :dark :light :light :light :light :light :dark]
       [:light :dark :light :light :light :dark :fdark :dark :light :dark :dark :light :dark :light :dark :light :dark :light :light :light :dark]
       [:flight :flight :flight :flight :flight :flight :flight :flight :fdark :dark :dark :dark :light :dark :light :dark :light :dark :light :dark :dark]
       [:fdark :fdark :fdark :fdark :fdark :fdark :fdark :flight :flight :dark :dark :dark :light :dark :dark :dark :light :dark :dark :dark :dark]
       [:fdark :flight :flight :flight :flight :flight :fdark :flight :flight :dark :light :dark :dark :dark :light :dark :dark :light :light :dark :light]
       [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :fdark :light :light :dark :light :dark :dark :dark :light :light :light :dark :dark]
       [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :flight :dark :dark :light :light :light :dark :dark :light :light :dark :dark :light]
       [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :fdark :light :dark :light :dark :light :light :light :dark :dark :light :light :dark]
       [:fdark :flight :flight :flight :flight :flight :fdark :flight :flight :light :dark :light :light :light :dark :dark :light :dark :light :dark :light]
       [:fdark :fdark :fdark :fdark :fdark :fdark :fdark :flight :fdark :light :light :light :dark :light :dark :light :dark :light :dark :dark :dark]]
      221))))

(ert-deftest
    test-02-encsym1 () "a simple qr code generation"
    (should
     (equal
      (matrix (encode-symbol "ciao" nil nil nil))
      [[:fdark :fdark :fdark :fdark :fdark :fdark :fdark :flight :fdark :dark :dark :dark :light :flight :fdark :fdark :fdark :fdark :fdark :fdark :fdark]
       [:fdark :flight :flight :flight :flight :flight :fdark :flight :fdark :dark :light :dark :dark :flight :fdark :flight :flight :flight :flight :flight :fdark]
       [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :flight :dark :dark :dark :light :flight :fdark :flight :fdark :fdark :fdark :flight :fdark]
       [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :fdark :light :light :light :light :flight :fdark :flight :fdark :fdark :fdark :flight :fdark]
       [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :flight :dark :light :dark :light :flight :fdark :flight :fdark :fdark :fdark :flight :fdark]
       [:fdark :flight :flight :flight :flight :flight :fdark :flight :flight :light :dark :dark :dark :flight :fdark :flight :flight :flight :flight :flight :fdark]
       [:fdark :fdark :fdark :fdark :fdark :fdark :fdark :flight :fdark :flight :fdark :flight :fdark :flight :fdark :fdark :fdark :fdark :fdark :fdark :fdark]
       [:flight :flight :flight :flight :flight :flight :flight :flight :fdark :dark :light :dark :dark :flight :flight :flight :flight :flight :flight :flight :flight]
       [:fdark :flight :fdark :fdark :flight :fdark :fdark :fdark :flight :dark :dark :dark :dark :flight :fdark :flight :flight :fdark :flight :fdark :fdark]
       [:light :dark :light :dark :dark :light :flight :light :dark :light :dark :dark :dark :dark :dark :light :light :light :light :light :dark]
       [:dark :dark :light :dark :dark :dark :fdark :dark :light :dark :light :dark :light :light :light :light :light :light :light :dark :dark]
       [:dark :light :light :light :dark :light :flight :dark :light :dark :dark :dark :light :light :dark :dark :dark :dark :light :light :dark]
       [:light :dark :dark :dark :dark :dark :fdark :dark :dark :light :light :light :dark :light :light :dark :light :light :light :light :light]
       [:flight :flight :flight :flight :flight :flight :flight :flight :fdark :light :dark :dark :light :light :dark :light :light :dark :light :light :light]
       [:fdark :fdark :fdark :fdark :fdark :fdark :fdark :flight :fdark :dark :dark :dark :dark :light :light :dark :light :dark :light :light :light]
       [:fdark :flight :flight :flight :flight :flight :fdark :flight :fdark :dark :light :light :light :light :light :dark :dark :dark :dark :light :light]
       [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :flight :light :dark :light :dark :dark :dark :dark :dark :dark :dark :dark :dark]
       [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :fdark :light :light :dark :light :light :dark :light :dark :dark :dark :dark :light]
       [:fdark :flight :fdark :fdark :fdark :flight :fdark :flight :fdark :dark :light :light :dark :light :dark :dark :light :dark :light :light :light]
       [:fdark :flight :flight :flight :flight :flight :fdark :flight :flight :dark :dark :light :light :dark :light :light :light :dark :light :light :dark]
       [:fdark :fdark :fdark :fdark :fdark :fdark :fdark :flight :fdark :light :light :light :light :dark :light :light :dark :light :light :light :light]])))

(ert t)
