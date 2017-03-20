<?php

  use yii\helpers\HTML;
  use yii\widgets\ActiveForm;
 ?>
 <div class="container">
<div class="row">
<div class="col-md-12 padding">


<h1>Sign Up</h1>
 <?php $form = ActiveForm::begin(); ?>
  <?= $form->field($model, 'name'); ?>
  <?= $form->field($model, 'email'); ?>

  <?= HTML::submitButton('Submit', ['class'=>'btn btn-success']); ?>
</div>
</div>
</div>
